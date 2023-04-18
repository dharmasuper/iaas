const knex = require('knex')({
    client: 'pg',
    connection: {
      host: 'your_host',
      database: 'your_database',
      user: 'your_username',
      password: 'your_password'
    }
  });
  
  async function createSchema(schemaName) {
    try {
      await knex.raw(`CREATE SCHEMA ${schemaName};`);
      console.log(`Schema ${schemaName} created successfully`);
    } catch (error) {
      console.error(`Error creating schema ${schemaName}: ${error}`);
    } finally {
      await knex.destroy();
    }
  }
  
  createSchema('your_schema_name');
  