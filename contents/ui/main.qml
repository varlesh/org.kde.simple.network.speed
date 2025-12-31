import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    readonly property int p_updateInterval: plasmoid.configuration.updateInterval || 1
    readonly property string p_interfaceName: plasmoid.configuration.interfaceName || "all"

    property var lastIn: 0
    property var lastOut: 0
    property var lastTime: 0
    property string upText: "0K▴"
    property string downText: "0K▾"

    PlasmaComponents.Label {
        id: metric
        text: "999.99M▾"
        font.family: "Noto Sans Mono, Liberation Mono, Monospace, monospace"
        font.pixelSize: Math.max(8, (root.height / 2) * 0.9)
        visible: false
    }

    Layout.minimumWidth: metric.implicitWidth
    Layout.preferredWidth: metric.implicitWidth
    Layout.maximumWidth: metric.implicitWidth

    Plasma5Support.DataSource {
        id: netSource
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            let lines = data.stdout.split('\n');
            let totalIn = 0; let totalOut = 0;

            for (let i = 2; i < lines.length; i++) {
                let line = lines[i].trim();
                if (!line) continue;

                let parts = line.replace(':', ' ').split(/\s+/);
                let iface = parts[0];

                if (iface === "lo") continue;

                if (root.p_interfaceName === "all" || iface === root.p_interfaceName) {
                    totalIn += parseInt(parts[1]) || 0;
                    totalOut += parseInt(parts[9]) || 0;
                }
            }

            let currentTime = Date.now();
            let timeDiff = (currentTime - root.lastTime) / 1000;

            if (root.lastTime > 0 && timeDiff > 0) {
                downText = formatSpeed((totalIn - lastIn) / timeDiff, "▾");
                upText = formatSpeed((totalOut - lastOut) / timeDiff, "▴");
            }

            lastIn = totalIn;
            lastOut = totalOut;
            root.lastTime = currentTime;
            disconnectSource(sourceName);
        }
    }

    Timer {
        interval: root.p_updateInterval * 1000;
        running: true;
        repeat: true;
        triggeredOnStart: true
        onTriggered: netSource.connectSource("cat /proc/net/dev")
    }

    function formatSpeed(bytes, arrow) {
        let num = 0;
        let unit = "K";

        if (bytes >= 1073741824) { // ГБ
            num = bytes / 1073741824;
            unit = "G";
        } else if (bytes >= 1048576) { // МБ
            num = bytes / 1048576;
            unit = "M";
        } else { // КБ
            num = bytes / 1024;
            unit = "K";
        }

        let s;
        if (unit === "K") {
            s = Math.floor(Math.max(0, num)).toString();
        } else {
            s = Number(Math.max(0, num).toFixed(2)).toString();
        }

        if (num >= 1000) s = "999";

        return s + unit + arrow;
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        PlasmaComponents.Label {
            text: root.downText
            font: metric.font
            Layout.fillWidth: true
            Layout.fillHeight: true
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
        }

        PlasmaComponents.Label {
            text: root.upText
            font: metric.font
            Layout.fillWidth: true
            Layout.fillHeight: true
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
        }
    }
}
