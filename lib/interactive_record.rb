require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

	def self.table_name
		self.to_s.downcase + "s"
	end

	def self.column_names
		sql = "pragma table_info('#{table_name}')"

		table_info = DB[:conn].execute(sql)
		table_info.collect do |row|
			row["name"]
		end
	end

	def initialize(options={})
		options.each do |property, value|
			self.send("#{property}=", value)
		end
	end

	def table_name_for_insert
		self.class.table_name
	end

	def col_names_for_insert
		self.class.column_names.reject do |col|
			col == "id"
		end.join(", ")
	end

	def values_for_insert
		self.class.column_names.collect do |col|
			"'#{send(col)}'" unless send(col).nil?
		end.compact.join(", ")
	end

	def save
		sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
		DB[:conn].execute(sql)
		@id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
	end

	def self.find_by_name(name)
		sql = "SELECT * FROM #{table_name} WHERE name = '#{name}'"
		DB[:conn].execute(sql)
	end

	def self.find_by(hash)
		attribute = hash.keys[0]
		value = hash.values[0]
		sql = "SELECT * FROM #{table_name} WHERE #{attribute} = '#{value}'"
		DB[:conn].execute(sql)
	end

end


