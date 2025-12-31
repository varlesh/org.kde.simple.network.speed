import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: root

    property alias cfg_updateInterval: intervalSpin.value
    property alias cfg_interfaceName: interfaceField.text

    property int cfg_updateIntervalDefault: 1
    property string cfg_interfaceNameDefault: "all"

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
    }
}
