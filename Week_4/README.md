# Week 4 - Simple API Deployment with Docker, Terraform, and AWS EC2
## Project Overview
- Create a [simple NestJS API](https://github.com/katiestruthers/Deploy-in-Public-NestJS)
  - Containerize with Docker by setting up a [Dockerfile](https://github.com/katiestruthers/Deploy-in-Public-NestJS/blob/main/Dockerfile)

- Setup AWS account
  - Attach new policy to IAM role in order to pull Docker images from Elastic Container Registry (ECR)

- Deploy your NestJS app
  - Push Docker image to ECR
  - Deploy to two private EC2 instances that pull the image from the ECR
  - Use a Load Balancer to distribute incoming traffic among the two EC2 instances

## Resources
- [NestJS Documentation](https://docs.nestjs.com/)
- [Tutorial: Setting Up Node.js on an Amazon EC2 Instance](https://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/setting-up-node-on-ec2-instance.html)
- [Dockerizing NestJS Application](https://medium.com/@sujan.dumaru.official/dockerizing-nestjs-application-c4b25139fe4c)
- Common Docker Commands:
  - `docker ps -a`: List all containers (running and stopped)
  - `docker run --rm -d -p 3000:3000 <image>`
    - `docker run <image>`: Create and start a new container from the image
    - `--rm`: Automatically deletes container when it stops running
    - `-d`: Run container in detached mode (useful when you don't want to wait for load balancers to become healthy)
    - `-p <host-port>:<container-port>`: Map ports
  - `docker stop <container>`: Stop a running container

## Final Result
<img src="Week4_Deployment_Success.png" width="750" />