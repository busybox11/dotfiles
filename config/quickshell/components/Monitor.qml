import QtQuick

Item {
  id: root

  required property string icon
  property real value: 0
  property string text: `${Math.round(value)}%`
  property real warnAt: Colors.warnAt
  property real critAt: Colors.critAt
  property bool lowIsBad: false
  property var history: []

  property var styles: ["graph", "graph_text", "text", "circle"]
  property string style: styles[0]

  readonly property bool isGraph: style === "graph" || style === "graph_text"
  readonly property bool isGraphText: style === "graph_text"
  readonly property bool isCircle: style === "circle"

  // styles that already render the value inline don't need a tooltip
  readonly property bool showsInlineText: root.style === "graph_text" || root.style === "text"
  readonly property bool tipEnabled: !root.showsInlineText

  readonly property int maxSamples: 40
  readonly property int fadePx: 64
  readonly property int graphWidth: 84

  readonly property string level: root.lowIsBad
    ? Colors.levelLow(value, warnAt, critAt)
    : Colors.level(value, warnAt, critAt)
  readonly property color textColor: root.style === "graph_text" || root.style === "text"
    ? Colors.foreground(level)
    : Colors.get("primary", "#ffffff")
  readonly property color plotColor: Colors.accent(level)

  implicitWidth: root.isGraph
    ? graphWidth
    : root.isCircle ? circleMetric.implicitWidth : textRow.implicitWidth
  implicitHeight: 40

  function pushSample(v) {
    root.value = v;
    const next = root.history.concat([v]);
    root.history = next.length > maxSamples ? next.slice(next.length - maxSamples) : next;
    if (root.isGraph)
      graph.requestPaint();
  }

  function cycleStyle() {
    const i = Math.max(0, root.styles.indexOf(root.style));
    root.style = root.styles[(i + 1) % root.styles.length];
  }

  onStyleChanged: {
    if (root.isGraph)
      graph.requestPaint();
  }

  onPlotColorChanged: {
    if (root.isGraph)
      graph.requestPaint();
  }

  // —— graph / graph_text ——
  Pill {
    id: graphPill
    visible: root.isGraph
    anchors.fill: parent
    icon: root.icon
    value: root.value
    warnAt: root.warnAt
    critAt: root.critAt
    lowIsBad: root.lowIsBad
    tint: Colors.accent(root.level)

    Canvas {
      id: graph
      parent: graphPill.contentItem
      anchors.fill: parent

      onPaint: {
        const ctx = getContext("2d");
        ctx.reset();

        const samples = root.history;
        if (samples.length === 0)
          return;

        const w = width;
        const h = height;
        const n = root.maxSamples;
        const c = Qt.color(root.plotColor);
        const fadePx = Math.min(root.fadePx, w);
        const fillMax = root.isGraphText ? 0.25 : 0.5;
        const strokeMax = root.isGraphText ? 0.5 : 0.8;

        const xAt = i => (i / (n - 1)) * w;
        const yAt = v => h - (Math.min(100, Math.max(0, v)) / 100) * h;

        const makeFade = maxAlpha => {
          const grad = ctx.createLinearGradient(0, 0, fadePx, 0);
          const steps = 10;
          for (let i = 0; i <= steps; i++) {
            const t = i / steps;
            const eased = t * t * (3 - 2 * t);
            grad.addColorStop(t, Qt.rgba(c.r, c.g, c.b, eased * maxAlpha));
          }
          return grad;
        };

        ctx.beginPath();
        ctx.moveTo(xAt(0), h);
        for (let i = 0; i < samples.length; i++)
          ctx.lineTo(xAt(i), yAt(samples[i]));
        ctx.lineTo(xAt(samples.length - 1), h);
        ctx.closePath();
        ctx.fillStyle = makeFade(fillMax);
        ctx.fill();

        ctx.beginPath();
        ctx.moveTo(xAt(0), yAt(samples[0]));
        for (let i = 1; i < samples.length; i++)
          ctx.lineTo(xAt(i), yAt(samples[i]));
        ctx.strokeStyle = makeFade(strokeMax);
        ctx.lineWidth = 1.5;
        ctx.lineJoin = "round";
        ctx.lineCap = "round";
        ctx.stroke();
      }
    }
  }

  BarText {
    visible: root.isGraphText
    anchors.right: parent.right
    anchors.rightMargin: 8
    anchors.verticalCenter: parent.verticalCenter
    topPadding: 0.5
    z: 1
    text: root.text
    color: root.textColor
    style: Text.Outline
    styleColor: "#00000033"
  }

  // —— circle ——
  CircleMetric {
    id: circleMetric
    visible: root.isCircle
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    icon: root.icon
    value: root.value
    color: root.plotColor
    iconColor: root.textColor
  }

  Row {
    id: textRow
    visible: root.style === "text"
    spacing: 8
    height: parent.height

    BarText {
      anchors.verticalCenter: parent.verticalCenter
      topPadding: 0.5
      text: root.icon
      color: root.textColor
    }

    BarText {
      anchors.verticalCenter: parent.verticalCenter
      text: root.text
      color: root.textColor
    }
  }

  MouseArea {
    anchors.left: parent.left
    width: 28
    height: parent.height
    z: 2
    cursorShape: Qt.PointingHandCursor
    onClicked: root.cycleStyle()
  }

  HoverHandler {
    id: hover
    target: root
  }

  // tooltip shown when the current style doesn't render the value inline
  Rectangle {
    id: tip
    visible: hover.hovered && root.tipEnabled
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.bottom
    anchors.topMargin: 4
    z: 5
    radius: 5
    color: Qt.rgba(0, 0, 0, 0.75)
    border.width: 1
    border.color: {
      const c = Qt.color(root.plotColor);
      return Qt.rgba(c.r, c.g, c.b, 0.4);
    }

    width: tipText.implicitWidth + 14
    height: tipText.implicitHeight + 6

    BarText {
      id: tipText
      anchors.centerIn: parent
      text: root.text
      color: Qt.rgba(1, 1, 1, 0.9)
    }
  }
}
