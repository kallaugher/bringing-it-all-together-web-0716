class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id=nil,attributes)
    @name = attributes[:name]
    @breed = attributes[:breed]
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs;
    SQL
    DB[:conn].execute(sql)
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?);
    SQL

    if self.id
      self.update
    else
      DB[:conn].execute(sql, self.name, self.breed)
    end

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    self
  end

  def self.create(attributes)
    new_dog = Dog.new(attributes)
    new_dog.save
  end

  def self.new_from_db(dog_data)
    dog_hash = {name: dog_data[1], breed: dog_data[2]}
    Dog.new(dog_data[0], dog_hash) 
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?;
    SQL

    results = DB[:conn].execute(sql, name)
    self.new_from_db(results[0])
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?;
    SQL

    results = DB[:conn].execute(sql, id)
    self.new_from_db(results[0])
  end

  def self.find_or_create_by(attributes)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?;
    SQL

    results = DB[:conn].execute(sql, attributes[:name], attributes[:breed])
    if results[0]
      dog = self.new_from_db(results[0])
    else
      dog = self.create(attributes)
    end
    dog
  end
end