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
        PlasmaComponents.TextField {
            id: inputTextField
            placeholderText: "Enter text to translate"
            Layout.fillWidth: true
        }

        // Drop-down to select the translation engine
        PlasmaComponents.ComboBox {
            id: engineComboBox
            Layout.fillWidth: true
            model: ["offline", "google", "openai"]
            currentIndex: 0
            onCurrentIndexChanged: {
                root.translationEngine = model[currentIndex]
            }
        }

        // Button to trigger translation
        PlasmaComponents.Button {
            id: translateButton
            text: "Translate"
            Layout.fillWidth: true
            onClicked: translateText(inputTextField.text)
        }

        // Read-only text area to display the translated text
        PlasmaComponents.TextArea {
            id: outputTextArea
            placeholderText: "Translation appears here..."
            readOnly: true
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
            // AI (LLM) translation using the OpenAI API
            var apiKey = Plasmoid.configuration.openaiApiKey;
            if (!apiKey) {
                outputTextArea.text = "OpenAI API key not set in configuration.";
                return;
            }
            // Use the model from configuration, defaulting to "gpt-4o-mini"
            var model = Plasmoid.configuration.openaiModel ? Plasmoid.configuration.openaiModel : "gpt-4o-mini";
            var url = "https://api.openai.com/v1/chat/completions";

            // The system prompt instructs the model to produce a native-sounding translation.
            var systemPrompt = "Translate the following into native sounding " + root.toLang + ". Make sure it doesn't sound auto-translated:\n\n";
            // The user's text is provided as the user message.
            var payload = {
                model: model,
                messages: [
                    { role: "system", content: systemPrompt },
                    { role: "user", content: text }
                ],
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
                            outputTextArea.text = response.choices[0].message.content.trim();
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
