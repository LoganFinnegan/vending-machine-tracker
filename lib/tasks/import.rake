require "csv"

def importCSV(file_path, model)
  CSV.foreach(file_path, headers: true) { |row| model.create!(row.to_hash) }
end

# order of operations and relations matter when creating. parent classes must be made first
namespace :csv_load do
  desc "imports owners csv into database"
  puts "Building owner objects" 
  task :owners => [:environment] do
    file_path = "db/data/owners.csv"
    importCSV(file_path, Owner)
  end
  
  desc "imports machines csv into database"
  puts "Building machine objects" 
  task :machines => [:environment] do
    file_path = "db/data/machines.csv"
    importCSV(file_path, Machine)
  end
  
  desc "imports snacks csv into database"
  puts "Building snack objects" 
  task :snacks => [:environment] do
    file_path = "db/data/snacks.csv"
    importCSV(file_path, Snack)
  end

  desc "imports machine_snacks csv into database"
  puts "Building machine_snack objects" 
  task :machine_snacks => [:environment] do
    file_path = "db/data/machine_snacks.csv"
    importCSV(file_path, MachineSnack)
  end

  desc "imports all csv into database"
  task :all => [:environment] do
    table = ["owners", "machines", "snacks", "machine_snacks"]
    table.each { |t| Rake::Task["csv_load:#{t}"].invoke }
  end
end

# set up primary key squence 
desc 'Resets Postgres auto-increment ID column sequences to fix duplicate ID errors'
task :reset_sequences => :environment do
  Rails.application.eager_load!
  ActiveRecord::Base.descendants.each do |model|
    unless model.attribute_names.include?('id')
      Rails.logger.debug "Not resetting #{model}, which lacks an ID column"
      next
    end
    begin
      max_id = model.maximum(:id).to_i + 1
      result = ActiveRecord::Base.connection.execute(
        "ALTER SEQUENCE #{model.table_name}_id_seq RESTART #{max_id};"
      )
      Rails.logger.info "Reset #{model} sequence to #{max_id}"
    rescue => e
      Rails.logger.error "Error resetting #{model} sequence: #{e.class.name}/#{e.message}"
    end
  end
end