import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("Settings")
        icon: "applications-system"
        source: "config/ConfigSettings.qml"
    }
}
