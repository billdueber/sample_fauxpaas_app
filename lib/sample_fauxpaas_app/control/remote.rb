require 'hanami/cli'
require_relative "../logger"

# Based on the following
#
# > ssh deployhost help
# Password:
# Password:
# Duo two-factor login for dueberb
#
# Enter a passcode or select one of the following options:
#
#  1. Duo Push to XXX-XXX-9591
#  2. Phone call to XXX-XXX-9591
#  3. SMS passcodes to XXX-XXX-9591
#
# Passcode or option (1-3): ddtltuibkdithjrhttftguedhttgghvvdclhgtitnlvc
# Commands:
#   fauxpaas caches <instance>                         # List cached releases f...
#   fauxpaas default_branch <instance> [<new_branch>]  # Display or set the def...
#   fauxpaas deploy <instance> [<reference>]           # Deploys the instance u...
#   fauxpaas exec <instance> <role> <bin> [<args>]     # Run an arbitrary command.
#   fauxpaas help [COMMAND]                            # Describe available com...
#   fauxpaas releases <instance>                       # List release history f...
#   fauxpaas restart <instance>                        # Restart the applicatio...
#   fauxpaas rollback <instance> [<cache>]             # Initiate a rollback to...
#   fauxpaas syslog SUBCOMMAND <instance> args...      # Interact with system l...
#
# Options:
#   -v, [--verbose], [--no-verbose]  # Show output from system commands
#   -u, --user=USER                  # The user running the action, defaults to $USER

module SampleFauxpaasApp
  class Control
    extend SampleFauxpaasApp::Logger

    VALID_TARGETS = %w[testing staging production]
    APP_NAME = 'sample_fauxpaas_app'
    PANIC_PAUSE = 5

    def self.valid_target?(t)
      target = t.downcase
      VALID_TARGETS.include? target
    end

    def self.validate_target!(t)
      if valid_target?(t)
        t.downcase
      else
        raise "Target must be one of [#{VALID_TARGETS.join(', ')}]"
      end
    end

    def self.remote_exec(target, cmd)
      logger.info "Telling #{target} to run #{cmd}"
      full_command = "ssh deployhost exec -v --env=RAILS_ENV:production #{APP_NAME}-#{target} app ruby #{cmd}"
      system full_command
    end

    class Deploy < Hanami::CLI::Command
      include SampleFauxpaasApp::Logger

      desc "Deploy to a valid target (testing/staging/production)"
      argument :target, required: true, desc: "Which deployment (testing/staging/production)"
      argument :branch, default: "master", desc: "Which branch/tag/SHA to deploy"

      def call(target:, branch:)
        target = Remote.validate_target!(target)
        logger.info "Deploying #{branch} to #{target.upcase}"
        sleep(Remote::PANIC_PAUSE)
        system "ssh deployhost deploy -v #{APP_NAME}-#{target} #{branch}"
      end
    end


    class Restart < Hanami::CLI::Command
      include SampleFauxpaasApp::Logger

      desc "Restart the puma server for a valid target"
      argument :target, required: true, desc: "Which deployment (testing/staging/production)"

      def call(target:)
        target = Remote.validate_target!(target)
        logger.info "Restarting puma server for #{target.upcase}"
        system "ssh deployhost restart #{APP_NAME}-#{target}"
      end
    end

    class Remote < Hanami::CLI::Command
      include SampleFauxpaasApp::Logger

      desc "Run a bin/control command on a remote server"
      argument :target, required: true, desc: "Which deployment (testing/staging/production)"
      argument :command, required: true, desc: "The command to run (e.g., \"solr reload\" IN DOUBLE QUOTES)"
      argument :arg1, required: false, default: ''
      argument :arg2, required: false, default: ''
      argument :arg3, required: false, default: ''

      def call(target:, command:, arg1:, arg2:, arg3:)
        target = Control.validate_target!(target)
        sleep(Control::PANIC_PAUSE)
        cmd = "bin/dromedary #{[command, arg1, arg2, arg3].join(' ').strip}"
        Control.remote_exec(target, cmd)
      end
    end

    class Exec < Hanami::CLI::Command
      include SampleFauxpaasApp::Logger

      desc "Run an arbitrary command using deploy exec"
      argument :target, required: true, desc: "Which deployment (testing/staging/production)"
      argument :command, required: true, desc: "The command to run (e.g., \"curl http://localhost...\" IN DOUBLE QUOTES)"

      def call(target:, command:)
        target = Control.validate_target!(target)
        sleep(Control::PANIC_PAUSE)
        Control.remote_exec(target, command)
      end
    end

  end
end
