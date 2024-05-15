# Workstation

Workstations are customs environments dockerized and based on Ubuntu:20.04 which provide several tools for developing and testing purposes.

## Usage

Build the image running the command `$ docker-compose-compose -f docker-compose-lxde.yml up -d`.

You can get inside the container via RDP with *Guacamole*. For this reason a [docker-compose.yml](docker-compose.yml) is provided for testing in local machines.

### Copying/pasting text

The Guacamole menu is a sidebar which is hidden until explicitly shown, you can show this menu by pressing **Ctrl+Alt+Shift**.

At the top of the Guacamole menu is a text area labeled "clipboard" along with some basic instructions:

> Text copied/cut within Guacamole will appear here. Changes to the text below will affect the remote clipboard.

The text area functions as an interface between the remote clipboard and the local clipboard. Text from the local clipboard can be pasted into the text area, causing that text to be sent to the clipboard of the remote desktop. Similarly, if you copy or cut text within the remote desktop, you will see that text within the text area, and can manually copy it into the local clipboard if desired.

To hide the menu, you press **Ctrl+Alt+Shift** again or swipe left across the screen.

## APPs

Open a terminal inside the workstation and run the following commands to start desired services

> IntelliJ IDEA

```sh
$ idea
```

> Visual Studio Code

Available on main menu

```sh
$ code
```

> Anaconda

```sh
$ conda*
$ anaconda*
```

> Knime

Available on main menu

```sh
$ knime
```

> DBeaver

Available on main menu

> Postman

```sh
$ postman
```

> Node.js

```sh
$ node
```

> Protractor

```sh
$ protractor
```

> Maven

```sh
$ mvn
```

## References

[Using Guacamole](https://guacamole.apache.org/doc/gug/using-guacamole.html#using-the-clipboard)
