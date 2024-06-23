# A Flutter Todo project with hive and docker



se thid commands to create and run a docker with this project.
```docker
docker build -t flutter-todo-app .
docker run -it -p 8080:8080 -v $(pwd)/hive_data:/app/hive_data flutter-todo-app
```

## To Do: 
 - Add better design
 - Improve it for production (delete unnecessary files)
 
