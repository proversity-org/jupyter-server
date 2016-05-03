# Jupyter Notebook Docker deployment with Sifu wrapper

#### Regarding Access Tokens

```text
Access tokens need to be generated in github against a user's profile.
The access token must be added to the elastic beanstalk environment variables,
this can be done via API or via AWS console.

The docker build will reference the access token environment variable
during its build and will be able to clone prviate repos. 
```
