# Motivation
This project is used to explore Core Bluetooth framework feature called state preservation and restoration.

Because I'm encountering  a problem at work that state restoration can't be triggered by system after termination.

# How this demo works
  *  **Peripheral**

    Peripheral always advertises a service which contains only one characteristic which in turn provids a dynamic value.

    At most of time, peripheral keeps advertising and providing dynamic value at background.

  *  **Central**

    Central always stays foreground. *Fetch it!* button triggers a read value request for characteristic of connected peripheral.
    It should be relaunched by system when it's terminated by system in order to release some memory for forground app.

# Outcome

Core Bluetooth state preservation and restoration (I only test in peripheral side) won't work in iOS 11.1.

That said, app (in this case, app as a peripheral) can't be relaunched by system after it's terminated by system in background mode.

But it works fine in iOS 9.3 and iOS 11.2 beta 1 and iOS 11.2 beta 2 ( I only test it in these three iOS versions). In these versions of system, not only delegate method *peripheralManager(_:willRestoreState:)* will be called, all functions also work as expected.

It seems like Apple has realized existence of this bug and has fixed it since 11.2 beta.

Hope it won't broke again : >
