# aws

Guide to github markdown syntax - [Read Guide](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax)

Link to learner lab - [Access Lab](https://awsacademy.instructure.com/courses/149548/modules/items/14489920)

# setup
```
#list instance profiles
aws iam list-instance-profiles

Current profiles:

- lab-instance-profile
- LabInstanceProfile
````

Download Files as Zip
```
#transfer Files with SCP
scp -i labsuser.pem \
package.zip \
ec2-user@3.91.174.252:~/
```

Unzip
```
unzip setup-files.zip
```

Edit permissions
```
chmod +x launch.sh
```

Run code
```
./launch.sh
```






