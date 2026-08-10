import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: root

    property alias cfg_updateInterval: intervalSpin.value
    property alias cfg_interfaceName: interfaceField.text
    property alias cfg_cpuUsage: cpuUsageField.text
    property alias cfg_memUsage: memUsageField.text
    property alias cfg_upSpeed: upSpeedField.text
    property alias cfg_downSpeed: downSpeedField.text
    property alias cfg_fontSize: fontSizeField.text
    property alias cfg_fontFamily: fontFamilyField.text

    property int cfg_updateIntervalDefault: 1
    property string cfg_interfaceNameDefault: "all"
    property string cfg_cpuUsageDefault: "CPU:"
    property string cfg_memUsageDefault: "MEM:"
    property string cfg_upSpeedDefault: "↑"
    property string cfg_downSpeedDefault: "↓"
    property string cfg_fontSizeDefault: "12"
    property string cfg_fontFamilyDefault: "Noto Mono"

    Kirigami.FormLayout {
        wideMode: true

        QQC2.SpinBox {
            id: intervalSpin
            Kirigami.FormData.label: i18n("Update interval (sec):")

            from: 1
            to: 3600
            stepSize: 1
            editable: true

            Layout.alignment: Qt.AlignRight
        }

        QQC2.TextField {
            id: interfaceField
            Kirigami.FormData.label: i18n("Interface:")
            placeholderText: "all"
            Layout.preferredWidth: Kirigami.Units.gridUnit * 6
            Layout.alignment: Qt.AlignRight
            horizontalAlignment: Text.AlignLeft
        }

        QQC2.TextField {
            id: cpuUsageField
            Kirigami.FormData.label: i18n("CPU Usage:")
            placeholderText: "CPU:"
            Layout.preferredWidth: Kirigami.Units.gridUnit * 6
            Layout.alignment: Qt.AlignRight
            horizontalAlignment: Text.AlignLeft
        }

        QQC2.TextField {
            id: memUsageField
            Kirigami.FormData.label: i18n("Memory Usage:")
            placeholderText: "MEM:"
            Layout.preferredWidth: Kirigami.Units.gridUnit * 6
            Layout.alignment: Qt.AlignRight
            horizontalAlignment: Text.AlignLeft
        }

        QQC2.TextField {
            id: upSpeedField
            Kirigami.FormData.label: i18n("Upload Speed:")
            placeholderText: "↑"
            Layout.preferredWidth: Kirigami.Units.gridUnit * 6
            Layout.alignment: Qt.AlignRight
            horizontalAlignment: Text.AlignLeft
        }

        QQC2.TextField {
            id: downSpeedField
            Kirigami.FormData.label: i18n("Download Speed:")
            placeholderText: "↓"
            Layout.preferredWidth: Kirigami.Units.gridUnit * 6
            Layout.alignment: Qt.AlignRight
            horizontalAlignment: Text.AlignLeft
        }
        QQC2.TextField {
            id: fontSizeField
            Kirigami.FormData.label: i18n("Font Size:")
            placeholderText: "12"
            Layout.preferredWidth: Kirigami.Units.gridUnit * 6
            Layout.alignment: Qt.AlignRight
            horizontalAlignment: Text.AlignLeft
        }
        QQC2.TextField {
            id: fontFamilyField
            Kirigami.FormData.label: i18n("Font Family:")
            placeholderText: "Noto Mono"
            Layout.preferredWidth: Kirigami.Units.gridUnit * 6
            Layout.alignment: Qt.AlignRight
            horizontalAlignment: Text.AlignLeft
        }
    }
}
