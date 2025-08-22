// Laragon PostgreSQL Configuration
// Konfigurasi khusus untuk environment Laragon

export const LARAGON_CONFIG = {
  // Laragon MySQL default settings
  development: {
    host: 'localhost',
    port: 3306,
    database: 'geotagging_usaha_dev',
    username: 'root',
    password: '', // Laragon biasanya tidak menggunakan password
    dialect: 'mysql' as const,
    ssl: false,
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000
    },
    logging: console.log,
    // Laragon specific settings
    timezone: 'Asia/Jakarta',
    define: {
      underscored: false,
      freezeTableName: false,
      charset: 'utf8',
      dialectOptions: {
        collate: 'utf8_general_ci'
      },
      timestamps: true
    }
  },

  // Test database untuk Laragon
  test: {
    host: 'localhost',
    port: 3306,
    database: 'geotagging_usaha_test',
    username: 'root',
    password: '',
    dialect: 'mysql' as const,
    ssl: false,
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000
    },
    logging: false
  }
}

// Database connection string untuk Laragon
export const getLaragonConnectionString = (dbName: string = 'geotagging_usaha_dev') => {
  return `mysql://root@localhost:3306/${dbName}`
}

// Check if running in Laragon environment
export const isLaragonEnvironment = () => {
  return process.platform === 'win32' && 
         (process.env.LARAGON_ROOT !== undefined || 
          process.env.PATH?.includes('laragon'))
}

// Get appropriate config based on environment
export const getDatabaseConfig = () => {
  if (isLaragonEnvironment()) {
    return LARAGON_CONFIG.development
  }
  
  // Fallback to environment variables
  return {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '3306'),
    database: process.env.DB_NAME || 'geotagging_usaha_dev',
    username: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    dialect: 'mysql' as const,
    ssl: false,
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000
    },
    logging: console.log
  }
}
