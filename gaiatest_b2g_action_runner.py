import os
import action_decorator
from base_action_runner import BaseActionRunner


class GaiatestB2GActionRunner(BaseActionRunner):

    action = action_decorator.action

    def __init__(self):
        group = self.parser.parser.add_argument_group('Gaiatest of B2G')
        group.add_argument('--localhost_port', default='2828', help='localhost port for marionette')
        group.add_argument('--testvars', required=True, help='path to a json file with any test data required')
        group.add_argument('--type', default='b2g', help='the type of test to run')
        group.add_argument('--tests', default='gaia/tests/python/gaia-ui-tests/gaiatest/tests/functional/manifest.ini',
                           help='test file, dir or manifest.')
        super(GaiatestB2GActionRunner, self).__init__()

    def parse_options(self):
        super(GaiatestB2GActionRunner, self).parse_options()

        self.testvars_file = self.options.testvars
        if not os.path.isfile(self.testvars_file):
            self.logger.error('No testvars file [%s].' % self.testvars_file)
            exit(1)
        else:
            self.logger.info('Set env[B2G_GAIATEST_TESTVARS] to [%s].' % self.testvars_file)
            os.environ['B2G_GAIATEST_TESTVARS'] = self.testvars_file

        self.localhost_port = self.options.localhost_port
        os.environ['B2G_GAIATEST_LOCAL_PORT'] = self.localhost_port

        self.type = self.options.type
        os.environ['B2G_GAIATEST_TYPE'] = self.type

        self.tests = os.path.abspath(self.options.tests)
        if not os.path.isfile(self.tests) and not os.path.isdir(self.tests):
            self.logger.error('must specify one or more test files, manifests, or directories')
            exit(1)
        os.environ['B2G_GAIATEST_TESTS'] = self.tests

    @action
    def b2g_download(self, action=False):
        if action:
            self.pre_commands.append('./gaiatest_b2g_download.sh')
        return self

    @action
    def b2g_flash(self, action=False):
        if action:
            self.pre_commands.append('./gaiatest_b2g_flash.sh')
        return self

    @action
    def b2g_run(self, action=False):
        if action:
            self.commands.append('./gaiatest_b2g_run.sh')
        return self
