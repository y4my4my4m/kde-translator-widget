import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami


PlasmoidItem {
    id: root
    width: 300
    height: 400
    preferredRepresentation: compactRepresentation

    // Store selected languages and translation engine
    property string fromLang: "English"
    property string toLang: "Japanese"
    property string translationEngine: "openai"  // can be "offline", "google", or "openai"
    // Property to hold conversation history for OpenAI
    property var openaiChatHistory: []
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 10
        // padding: 10

        RowLayout {
            spacing: 10
            // “From” language selector
            PlasmaComponents.ComboBox {
                id: fromLangCombo
                Layout.fillWidth: true
                model: ["English", "Spanish", "German", "French", "Italian", "Japanese", "Chinese (Mandarin)", "Chinese (Cantonese)", "Russian"]  // Extend this list as needed
                currentIndex: model.indexOf(root.fromLang)
                onCurrentIndexChanged: {
                    root.fromLang = model[currentIndex]
                }
            }

            // Swap button to reverse languages
            PlasmaComponents.Button {
                text: "⇄"
                onClicked: {
                    var temp = root.fromLang;
                    root.fromLang = root.toLang;
                    root.toLang = temp;
                    fromLangCombo.currentIndex = fromLangCombo.model.indexOf(root.fromLang)
                    toLangCombo.currentIndex = toLangCombo.model.indexOf(root.toLang)
                }
            }

            // “To” language selector
            PlasmaComponents.ComboBox {
                id: toLangCombo
                Layout.fillWidth: true
                model: ["English", "Spanish", "German", "French", "Italian", "Japanese", "Chinese (Mandarin)", "Chinese (Cantonese)", "Russian"]
                currentIndex: model.indexOf(root.toLang)
                onCurrentIndexChanged: {
                    root.toLang = model[currentIndex]
                }
            }
        }

        // Text input where the user enters text to be translated
        PlasmaComponents.TextArea {
            id: inputTextField
            placeholderText: "Enter text to translate"
            readOnly: false
            wrapMode: TextEdit.Wrap
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        // Drop-down to select the translation engine
        PlasmaComponents.ComboBox {
            id: engineComboBox
            Layout.fillWidth: true
            model: ["offline", "google", "openai"]
            currentIndex: 2
            onCurrentIndexChanged: {
                root.translationEngine = model[currentIndex]
            }
        }

        RowLayout {
            spacing: 10
            PlasmaComponents.Button {
                id: translateButton
                text: "Translate"
                Layout.fillWidth: true
                onClicked: translateText(inputTextField.text)
            }

            PlasmaComponents.Button {
                id: newTopicButton
                text: "+"
                visible: root.translationEngine === "openai"
                Layout.preferredWidth: 40
                PlasmaComponents.ToolTip {
                    text: "Start a new topic. The previously translated text is part of the AI conversation until a new topic is started, this is to help translation accuracy by keeping the AI aware of context."
                }
                onClicked: {
                    root.openaiChatHistory = [];
                    outputTextArea.text = "New topic started. Conversation cleared.";
                }
            }
        }

        // Read-only text area to display the translated text
        PlasmaComponents.TextArea {
            id: outputTextArea
            placeholderText: "Translation appears here..."
            readOnly: true
            wrapMode: TextEdit.Wrap
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    // Function to perform translation based on selected engine
    function translateText(text) {
        if (text.trim() === "") {
            outputTextArea.text = "Please enter text to translate."
            return;
        }
        if (root.translationEngine === "offline") {
            // Offline/dummy translation logic: for example, reverse the text.
            outputTextArea.text = text.split("").reverse().join("");
        } else if (root.translationEngine === "google") {
            // Google Translate API call
            var apiKey = Plasmoid.configuration.googleApiKey;
            if (!apiKey) {
                outputTextArea.text = "Google API key not set in configuration."
                return;
            }
            // Build the URL and parameters (this is a simplified example)
            var url = "https://translation.googleapis.com/language/translate/v2?key=" + apiKey;
            var params = {
                q: text,
                source: root.fromLang,
                target: root.toLang,
                format: "text"
            };

            var xhr = new XMLHttpRequest();
            xhr.open("POST", url);
            xhr.setRequestHeader("Content-Type", "application/json");
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status === 200) {
                        var response = JSON.parse(xhr.responseText);
                        if (response.data && response.data.translations &&
                            response.data.translations.length > 0) {
                            outputTextArea.text = response.data.translations[0].translatedText;
                        } else {
                            outputTextArea.text = "Translation error: unexpected response.";
                        }
                    } else {
                        outputTextArea.text = "Translation error: " + xhr.status;
                    }
                }
            }
            xhr.send(JSON.stringify(params));
        } else if (root.translationEngine === "openai") {
           // AI (LLM) translation using the OpenAI API with conversation context
            var apiKey = Plasmoid.configuration.openaiApiKey;
            if (!apiKey && !Plasmoid.configuration.customURL) {
                outputTextArea.text = "OpenAI API key not set in configuration.";
                return;
            }
            // Use the model from configuration, defaulting to "gpt-4o-mini"
            var model = Plasmoid.configuration.openaiModel ? Plasmoid.configuration.openaiModel : "gpt-4o-mini";
            
            // If conversation history is empty, add the system prompt
            if (root.openaiChatHistory.length === 0) {
                var systemPrompt = Plasmoid.configuration.systemPrompt.replace("${root.toLang}", root.toLang);
                root.openaiChatHistory.push({ role: "system", content: systemPrompt });
            }
            
            // Add the user's message to the conversation history.
            root.openaiChatHistory.push({ role: "user", content: text });
            
            var url = Plasmoid.configuration.customURL ? Plasmoid.configuration.customURL : "https://api.openai.com/v1/chat/completions";
            var payload = {
                model: model,
                messages: root.openaiChatHistory,
                temperature: 0.3
            };

            var xhr = new XMLHttpRequest();
            xhr.open("POST", url);
            xhr.setRequestHeader("Content-Type", "application/json");
            xhr.setRequestHeader("Authorization", "Bearer " + apiKey);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status === 200) {
                        var response = JSON.parse(xhr.responseText);
                        if (response.choices && response.choices.length > 0) {
                            // Add the assistant's reply to the history.
                            var assistantMessage = { role: "assistant", content: response.choices[0].message.content.trim() };
                            root.openaiChatHistory.push(assistantMessage);
                            outputTextArea.text = assistantMessage.content;
                        } else {
                            outputTextArea.text = "Translation error: unexpected response.";
                        }
                    } else {
                        outputTextArea.text = "Translation error: " + xhr.status;
                    }
                }
            }
            xhr.send(JSON.stringify(payload));
        }
    }
}
