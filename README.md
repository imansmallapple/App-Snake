# App-Snake

## Content table
1. [Overview](#overview)
2. [Requirements](#requirements)
3. [Features](#features)
4. [Setup Instructions](#setup-instructions)
5. [Quick Start Guide](#quick-start-guide)
6. [Link](#link)

## Overview
Distributed Snake Game is a single-player adaptation of the classic Snake game, built on OpenHarmony to demonstrate distributed control and display across seperate devices. It separates control input and game rendering, offering a clear showcase of cross-device collaboration.

UI effects is as following:
![Image1.png](images%2FImage1.png)

> **Note:**
>
> This example uses system interfaces, so you need to manually replace the Full SDK to compile successfully. For specific steps, refer to the [Replacement Guide](https://docs.oniroproject.org/application-development/environment-setup-config/full-public-sdk/).

## Requirements
* Two OpenHarmony-compatible devices (e.g., `Dayu200 Development Board` and `OpenHarmony Developer Phone`)
* Valid network connection
* Proper permissions (`ACCESS_SERVICE_DM` and `DISTRIBUTED_DATASYNC`)

## Features
* Discover nearby devices on the same networkAdd commentMore actions
* Authenticate and pair discovered devices using a PIN code
* Send `command` from controller to receiver in real time

## Setup Instruction
**1. Clone the repository**
```bash
git clone https://github.com/imansmallapple/app-Snake.git
```

**2. Build and Deploy**
* Ensure you are using API level 11Add commentMore actions
* Confirm your app is a `system-level` application
* Sign the application with valid signature configurations
* Connect two OpenHarmony-compatible devices (e.g., Dayu200 Development Board and OpenHarmony Developer Phone)
* Ensure both devices are connected to the same network
* Click the `Run` button in DevEco Studio to install the application

> **Note:**
>
> See this [tutorial](https://docs.oniroproject.org/application-development/codeLabs/) for how to configure the project as a `system-level` application.

## Quick Start Guide
**1. Install the app on both devices**
Make sure both devices support OpenHarmony and are connected to the same network.

**2. Pair device**
* Tap the **Find Nearby Device** button
* Select the receiver device from the pop-up list
* A verification box will appear on the receiver device; after it is accepted, a random PIN code will be generated
* Enter the PIN code on the sender device
* Pairing is complete

**3. Determine roles**
Once paired, the initiating device is labeled as the `Sender`, and the other as the `Receiver`.

**4. Game start**
- Click **Start** button the start the game, user can control the snake direction by tapping the direction button on the controller.
- User can also control the game status with with different buttons: `Stop`, `Continue`, `Restart` and `End`.

**5. Game Rules**
- The game is end once snake hit on the wall, user can grant 10 scores by eating a food.

**6. Unbind if needed**
- Tap **Unbind** to disconnect the paired device and reset the session.

## Link
The project is implemented based on provided template, check more information from this [repo](https://github.com/eclipse-oniro4openharmony/app-SuperDeviceDemo).