import QtQuick
import qs.components

Row {
  spacing: 24

  Monitor {
    id: tempMon
    icon: ""
    style: "text"
    text: `${Math.round(value)}°C`
    warnAt: 70
    critAt: 80
  }

  Monitor {
    id: fanMon
    icon: "󰈐"
    style: "text"
    text: `${Math.round(value)}`
    warnAt: 6000
    critAt: 7500
  }

  Hwmon {
    id: sensors
    onTempSample: celsius => tempMon.pushSample(celsius)
    onFanSample: rpm => fanMon.pushSample(rpm)
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: sensors.reload()
  }
}
