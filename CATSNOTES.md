When responding to onNewWindow requests from a Web using a Web in a custom node, the original web thread would be blocked.
While using a timeout, nothing would be blocked but the original web seems to fail to get the new tab's handler.
Therefore we need further investigation on this.
