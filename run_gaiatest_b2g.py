#!/usr/bin/python

import os
from gaiatest_b2g_action_runner import GaiatestB2GActionRunner


def main():
    runner = GaiatestB2GActionRunner()
    # actions and run
    #runner.b2g_download().b2g_flash()
    runner.b2g_run()
    runner.run()

if __name__ == '__main__':
    main()
