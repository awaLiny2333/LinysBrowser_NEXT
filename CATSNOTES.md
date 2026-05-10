1. It seems that Status management V2 is repainting every old window when a new window is created, 
  so creating new windows is getting more and more slowly when more and more windows are created.
2. Hiding not focused window contents using if (focused) { render(); } can substantially address this issue,
  but I think we need further investigation into this in order to come up with a more humane & elegant resolution.
