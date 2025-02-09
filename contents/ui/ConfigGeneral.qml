import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami


Item {
    id: page
    width: childrenRect.width
    height: childrenRect.height

    property alias cfg_googleApiKey: googleKeyField.text
    property alias cfg_openaiApiKey: openaiKeyField.text
    property alias cfg_openaiModel: openaiModelCombo.currentText
    property alias cfg_systemPrompt: systemPromptField.text

    Kirigami.FormLayout {
        anchors.left: parent.left
        anchors.right: parent.right


        QQC2.TextField {
            Kirigami.FormData.label: i18n("Google Translate API Key")
            id: googleKeyField
            placeholderText: i18n("Enter your Google Translate API key")
        }

        QQC2.TextField {
            Kirigami.FormData.label: i18n("OpenAI API Key")
            id: openaiKeyField
            placeholderText: i18n("Enter your OpenAI API key")
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("OpenAI Model")
            id: openaiModelCombo
            model: ["gpt-4o", "gpt-4o-mini"]
            currentIndex: model.indexOf("gpt-4o-mini")
        }


        QQC2.TextField {
            Kirigami.FormData.label: i18n("System Prompt")
            id: systemPromptField
            placeholderText: i18n("Enter the default System Prompt")
        }
    }
}


