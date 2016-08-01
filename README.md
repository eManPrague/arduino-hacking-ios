Arduino Hacking
===============

This iPhone (iOS 9+) and watchOS 2 demo app for eMan IoT workshop.

Features
--------

1. Control state of diods via MQTT broker (RabbitMQ)
2. Show online/offline state of the edge device (Arduino)

Client/server communication
---------------------------

The app communicates with MQTT broker via these topics:

1. `arduino/:id/:color` – setting diod state where :color is one of `red`, `green` or `blue` (publish/subscribe)
2. `arduino/:id/status` – online state of the edge device (subscribe)

Payload is always `0x0` (off) or `0x1` (on), QoS is 1 fo publish and subscribe and keep alive timer is 1s. Messages are published with a retain flag set to 1.

Important files
---------------

* `Constants.swift` – Configuration options, **MQTT host, username and password need to be configured**
* `Client.swift` – Client for diod controlling, uses MQTT

Dependencies
------------

Dependencies (only CocoaMQTT library at this moment) are handled by carthage and are bundled in the git repo. Carthage needs to be installed at `/usr/local/bin/carthage` to build the product.

Related
-------

* [Arduino Hacking - Arduino](https://github.com/eManPrague/arduino-hacking-arduino)
* [Arduino Hacking - Web client](https://github.com/eManPrague/arduino-hacking-web)


License
-------

Arduino Hacking for iOS and watchOS is released under the [MIT License](http://www.opensource.org/licenses/MIT).
