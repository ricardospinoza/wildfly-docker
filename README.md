# Wildfly Docker

That repo is used to run Wildfly server as container on docker. **Not available on Docker Hub yet.**

---

_Default configutation:_

- _Wildfly 22.0.1_

# Usage

To use repository is necessary follow these steps:

## Build Image

The command to build a Docker image from the specified Dockerfile in the current directory (.) and tag it with the name wildfly-image. Here's what each part of the command means:

```
docker build -t wildfly-image .
```

Have a file in `/resources/cli/(install-datasource|install-driver).sample.cli` to use as example of implementation.

This command will run in default mode. That mode will not install any driver or set any datasource. Now if you are looking for a solution to use these items, you can go for two options:

- You can access Wildfly admin console and set manualy all as you want.
- You can run the command below and that will use `/resources/cli/*.enviroment.*` as you set your ENV.

```
docker build --build-arg="ENV=dev|prod|test" -t wildfly-image .
```

**Be Aware:** If you are setting some kind of driver, probably you are going to use a jar and that shoud be present in `/resources/jars/`.

# Run Container

To run the created image as container is recommended to use the command below:

```
docker run -p 8080:8080 -p 9990:9990 -p 5432:5432 -v ./deployments:/deployments --name wildfly-container -c 2048 -it -d wildfly-image
```

A brief explanation about that command:

**-p:** The flag is used to publish (expose) container ports to the host system.

- 8080 - HTTP Port
- 9990 - Management Port
- 5432 - Database Port

**-v:** The flag is used to create a volume binding between the host and the container. By default is being used deployments folder to deploy any war file needed.

**-c:** The flag sets the CPU shares for the container. The value 2048 is the same applied on `JAVA_OPTS` inside of dockerfile.
