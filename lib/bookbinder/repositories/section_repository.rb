module Bookbinder
  module Repositories
    class SectionRepository
      SHARED_CACHE = {}

      def initialize(logger,
                     store: nil,
                     build: nil)
        @build = build
        @store = store
        @logger = logger
      end

      def get_instance(attributes,
                       vcs_repo: nil,
                       destination_dir: Dir.mktmpdir,
                       target_tag: nil)
        store.fetch([attributes, vcs_repo.path_to_local_repo]) {
          acquire(attributes, destination_dir, target_tag, vcs_repo)
        }
      end

      private

      attr_reader(:build, :store, :section_hash, :logger,
                  :destination_dir, :target_tag)

      def acquire(section_hash, destination_dir, target_tag, vcs_repo)
        repository_config = section_hash['repository']
        raise "section repository '#{repository_config}' is not a hash" unless repository_config.is_a?(Hash)
        raise "section repository '#{repository_config}' missing name key" unless repository_config['name']
        logger.log "Gathering #{repository_config['name'].cyan}"
        store[[section_hash, vcs_repo.path_to_local_repo]] =
          build[vcs_repo.copied_to,
                vcs_repo.full_name,
                vcs_repo.copied?,
                section_hash['subnav_template'],
                destination_dir,
                vcs_repo.directory]
      end
    end
  end
end