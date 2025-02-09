import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

Item {
    width: 300
    ColumnLayout {
        anchors.fill: parent
        spacing: 10
        padding: 10

        // Configuration for Google Translate API key
        PlasmaComponents.GroupBox {
            title: "Google Translate API"
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 5
                PlasmaComponents.TextField {
                    id: googleKeyField
                    Layout.fillWidth: true
                    placeholderText: "Enter Google API Key"
                    text: plasmoid.config.googleApiKey ? plasmoid.config.googleApiKey : ""
                    onTextChanged: {
                        plasmoid.config.googleApiKey = text;
                    }
                }
            }
        }

        // Configuration for OpenAI API key
        PlasmaComponents.GroupBox {
            title: "OpenAI API"
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 5
                PlasmaComponents.TextField {
                    id: openaiKeyField
                    Layout.fillWidth: true
                    placeholderText: "Enter OpenAI API Key"
                    text: plasmoid.config.openaiApiKey ? plasmoid.config.openaiApiKey : ""
                    onTextChanged: {
                        plasmoid.config.openaiApiKey = text;
                    }
                }
            }
        }
    }
}
