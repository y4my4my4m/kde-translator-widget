import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

QQC2.Pane {
    id: root
    // width: childrenRect.width
    // height: childrenRect.height


    property alias cfg_googleApiKey: googleKeyField.text
    property alias cfg_openaiApiKey: openaiKeyField.text
    property alias cfg_openaiModel: openaiModelCombo.currentText

    Kirigami.FormLayout {
        anchors.left: parent.left
        anchors.right: parent.right

        Kirigami.Section {
            title: i18n("Google Translate API Key")
            Kirigami.TextField {
                id: googleKeyField
                placeholderText: i18n("Enter your Google Translate API key")
            }
        }

        Kirigami.Section {
            title: i18n("OpenAI API Key")
            Kirigami.TextField {
                id: openaiKeyField
                placeholderText: i18n("Enter your OpenAI API key")
            }
        }

        Kirigami.Section {
            title: i18n("OpenAI Model")
            Kirigami.ComboBox {
                id: openaiModelCombo
                model: ["gpt-4o", "gpt-4o-mini"]
                currentIndex: model.indexOf("gpt-4o-mini")
            }
        }
    }
}


