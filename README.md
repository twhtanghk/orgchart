# orgchart

Organization chart in directory view with drag and drop

## Configuration

Configured by environment variables in [.env](https://github.com/twhtanghk/orgchart/blob/master/.env)

## Start orgchart
1. download '.env' and customize env variables if required
2. update docker-compose.yml if required
```
docker-compose -f docker-compose.yml up
```

## API
1. 'GET /api/user' to return users without supervisor defined (root node)
2. 'GET /api/user/:email' to return user details for specified email
3. 'POST /api/user' to create user with provided details
4. 'PUT /api/user/:email' to define user's supervisor for specified email
5. 'DELETE /api/user/:email' to delete user with specified email


## Usage
1. list and expand node to view user's subordinates
2. update supervisor by drag and drop node from current supervisor to other user
