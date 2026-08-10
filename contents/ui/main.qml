import QtQuick
import QtQuick.Controls 2
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18nc("@item", "Open System Monitor")
            icon.name: "utilities-system-monitor"
            onTriggered: exec.connectSource("kstart5 plasma-systemmonitor")
        }
    ]

    readonly property string p_queryNetCommand: "cat /proc/net/dev"
    readonly property string p_queryCpuCommand: "cat /proc/stat | head -n 1"
    readonly property string p_queryMemCommand: "cat /proc/meminfo"
    readonly property string p_launchSystemMonitorCommand: "kstart5 plasma-systemmonitor"

    readonly property int p_updateInterval: plasmoid.configuration.updateInterval || 1
    readonly property string p_interfaceName: plasmoid.configuration.interfaceName || "all"
    readonly property string p_cpuUsage: plasmoid.configuration.cpuUsage || "CPU:"
    readonly property string p_memUsage: plasmoid.configuration.memUsage || "MEM:"
    readonly property string p_upSpeed: plasmoid.configuration.upSpeed || "↑"
    readonly property string p_downSpeed: plasmoid.configuration.downSpeed || "↓"
    readonly property string p_fontSize: plasmoid.configuration.fontSize || "12"
    readonly property string p_fontFamily: plasmoid.configuration.fontFamily || "Noto Mono"

    property var lastIn: 0
    property var lastOut: 0
    property var lastCpuTotal: 0
    property var lastCpuWork: 0
    property var lastTime: 0
    property string upText: p_upSpeed + "  0B/s"
    property string downText: p_downSpeed + "  0B/s"
    property string cpuText: p_cpuUsage + " 0%"
    property string memText: p_memUsage + " 0%"

    PlasmaComponents.Label {
        id: metric
        text: p_cpuUsage + "99% " + p_downSpeed + "999M/s"
        //font.family: "Noto Sans Mono, Noto Mono, Liberation Mono, Monospace, monospace"
        font.family: p_fontFamily
        font.pixelSize: parseInt(p_fontSize)
        visible: false
    }

    Layout.minimumWidth: metric.implicitWidth
    Layout.preferredWidth: metric.implicitWidth
    Layout.maximumWidth: metric.implicitWidth

    Plasma5Support.DataSource {
        id: exec
        engine: "executable"
        connectedSources: []
        onNewData: function (sourceName, data) {
            disconnectSource(sourceName);
            if (sourceName === root.p_queryNetCommand) {
                parseNetData(data);
            } else if (sourceName === root.p_queryCpuCommand) {
                parseCpuData(data);
            } else if (sourceName === root.p_queryMemCommand) {
                parseMemData(data);
            }
        }
    }

    function parseNetData(data) {
        let lines = data.stdout.split('\n');
        let totalIn = 0;
        let totalOut = 0;

        for (let i = 2; i < lines.length; i++) {
            let line = lines[i].trim();
            if (!line)
                continue;

            let parts = line.replace(':', ' ').split(/\s+/);
            let iface = parts[0];

            if (iface === "lo")
                continue;

            if (root.p_interfaceName === "all" || iface === root.p_interfaceName) {
                totalIn += parseInt(parts[1]) || 0;
                totalOut += parseInt(parts[9]) || 0;
            }
        }

        let currentTime = Date.now();
        let timeDiff = (currentTime - root.lastTime) / 1000;

        if (root.lastTime > 0 && timeDiff > 0) {
            downText = formatSpeed((totalIn - lastIn) / timeDiff, p_downSpeed);
            upText = formatSpeed((totalOut - lastOut) / timeDiff, p_upSpeed);
        }

        lastIn = totalIn;
        lastOut = totalOut;
        root.lastTime = currentTime;
    }

    function parseCpuData(data) {
        let lines = data.stdout.split('\n');
        let cpuTotal = 0;
        let cpuWork = 0;
        let line = lines[0].trim();
        let parts = line.split(/\s+/);

        cpuWork = (parseInt(parts[1]) || 0) + (parseInt(parts[2]) || 0) + (parseInt(parts[3]) || 0);
        cpuTotal = cpuWork + (parseInt(parts[4]) || 0) + (parseInt(parts[5]) || 0) + (parseInt(parts[6]) || 0) + (parseInt(parts[7]) || 0) + (parseInt(parts[8]) || 0);

        let cpuUsage = (cpuWork - lastCpuWork) / (cpuTotal - lastCpuTotal) * 100;
        if (cpuUsage >= 100)
            cpuUsage = 99;
        let usageText = Math.floor(cpuUsage).toString();
        cpuText = p_cpuUsage + " ".repeat(2 - usageText.length) + usageText + "%";

        lastCpuWork = cpuWork;
        lastCpuTotal = cpuTotal;
    }

    function parseMemData(data) {
        let lines = data.stdout.split('\n');
        let memTotal = 0;
        let memAvailable = 0;
        let line0 = lines[0].trim();
        let parts0 = line0.split(/\s+/);
        let line2 = lines[2].trim();
        let parts2 = line2.split(/\s+/);

        memTotal = parseInt(parts0[1]) || 0;
        memAvailable = parseInt(parts2[1]) || 0;

        let memUsage = (memTotal - memAvailable) / memTotal * 100;
        if (memUsage >= 100)
            memUsage = 99;
        let usageText = Math.floor(memUsage).toString();
        memText = p_memUsage + " ".repeat(2 - usageText.length) + usageText + "%";
    }

    Timer {
        interval: root.p_updateInterval * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            exec.connectSource("cat /proc/net/dev");
            exec.connectSource("cat /proc/stat | head -n 1");
            exec.connectSource("cat /proc/meminfo");
        }
    }

    function formatSpeed(bytes, arrow) {
        let num = 0;
        let unit = "B";

        if (bytes < 0) {
            num = 0;
            unit = "B";
        } else if (bytes < 1000) {
            num = bytes;
            unit = "B";
        } else if (bytes < 1000 * 1024) {
            num = bytes / 1024;
            unit = "K";
        } else if (bytes < 1000 * 1024 * 1024) {
            num = bytes / (1024 * 1024);
            unit = "M";
        } else if (bytes < 1000 * 1024 * 1024 * 1024) {
            num = bytes / (1024 * 1024 * 1024);
            unit = "G";
        } else if (bytes < 1000 * 1024 * 1024 * 1024 * 1024) {
            num = bytes / (1024 * 1024 * 1024 * 1024);
            unit = "T";
        } else {
            num = bytes / (1024 * 1024 * 1024 * 1024 * 1024);
            unit = "P";
        }

        let s;
        if (num < 10) {
            s = (Math.floor(num * 10) / 10).toString();
            s = " ".repeat(3 - s.length) + s;
        } else if (num < 100) {
            s = " " + Math.floor(num).toString();
        } else {
            s = Math.floor(num).toString();
        }

        return arrow + s + unit + "/s";
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        PlasmaComponents.Label {
            text: root.cpuText + root.upText
            font: metric.font
            Layout.fillWidth: true
            Layout.fillHeight: true
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
        }

        PlasmaComponents.Label {
            text: root.memText + root.downText
            font: metric.font
            Layout.fillWidth: true
            Layout.fillHeight: true
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
        }
    }
}
