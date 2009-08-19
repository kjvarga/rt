namespace :db do
	desc "Dump schema and data to db/schema.rb and db/data.yml, or the file specified by DATA_FILE"
	task(:dump => [ "db:schema:dump", "db:data:dump" ])

	desc "Load schema and data from db/schema.rb and db/data.yml, or the file specified by DATA_FILE"
	task(:load => [ "db:schema:load", "db:data:load" ])

	namespace :data do
		def db_dump_data_file
			"#{RAILS_ROOT}/db/data.yml"
		end

		desc "Dump contents of database to db/data.yml, or the file specified by DATA_FILE"
		task(:dump => :environment) do
		  file = ENV['DATA_FILE'] || db_dump_data_file
		  batch_size = ENV['BATCH_SIZE'].nil? ? YamlDb::Dump::RECORDS_PER_PAGE : ENV['BATCH_SIZE'].to_i
			YamlDb.dump(file, batch_size)
		end

		desc "Load contents of db/data.yml into database, or the file specified by DATA_FILE"
		task(:load => :environment) do
		  file = ENV['DATA_FILE'] || db_dump_data_file
			YamlDb.load file
		end
	end
end
