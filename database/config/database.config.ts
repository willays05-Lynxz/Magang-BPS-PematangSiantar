export const DATABASE_CONFIG = {
  // Development database configuration
  development: {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432'),
    database: process.env.DB_NAME || 'geotagging_usaha_dev',
    username: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'password',
    dialect: 'postgresql' as const,
    ssl: false,
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000
    },
    logging: console.log
  },

  // Production database configuration
  production: {
    host: process.env.DB_HOST || '',
    port: parseInt(process.env.DB_PORT || '5432'),
    database: process.env.DB_NAME || '',
    username: process.env.DB_USER || '',
    password: process.env.DB_PASSWORD || '',
    dialect: 'postgresql' as const,
    ssl: {
      require: true,
      rejectUnauthorized: false
    },
    pool: {
      max: 20,
      min: 5,
      acquire: 60000,
      idle: 300000
    },
    logging: false
  },

  // Test database configuration
  test: {
    host: process.env.DB_HOST_TEST || 'localhost',
    port: parseInt(process.env.DB_PORT_TEST || '5432'),
    database: process.env.DB_NAME_TEST || 'geotagging_usaha_test',
    username: process.env.DB_USER_TEST || 'postgres',
    password: process.env.DB_PASSWORD_TEST || 'password',
    dialect: 'postgresql' as const,
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

export const getConfig = (environment: string = process.env.NODE_ENV || 'development') => {
  return DATABASE_CONFIG[environment as keyof typeof DATABASE_CONFIG] || DATABASE_CONFIG.development
}
