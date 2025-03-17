# **Helm-based PSQL User & Role Management**  

This project automates **PostgreSQL role and user creation** along with **granting database permissions** using **Helm** and **Kubernetes Jobs**. It ensures a **secure, repeatable, and scalable** approach to database access management within **Amazon PSQL** or local PostgreSQL instances.  

---

## **🚀 Features**
- **Automated Role & User Creation** via Helm  
- **Secure Password Management** using Kubernetes Secrets  
- **Database Grants & Permissions Enforcement**  
- **Designed for PSQL but Works Locally with Minikube**  

---

## **📂 Project Structure**
```
helm-db-init/
│── templates/
│   ├── user-roles.yaml          # Create roles
    ├── grants.yaml              #Grant Permissions
│   ├── configmap.yaml    # ConfigMap containing SQL scripts
│── values.yaml           # Configuration file (references Secrets)
│── README.md             # Documentation
```

---

## **🛠️ Setup & Deployment**  

### **1️⃣ Prerequisites**
- **Helm** installed (`helm version`)
- **Kubernetes cluster** (EKS, Minikube, or any K8s setup)
- **PostgreSQL PSQL instance** (or a local PostgreSQL instance)
- **kubectl** configured (`kubectl get nodes`)

---

### **2️⃣ Securely Store Database Credentials**
Create a Kubernetes Secret to store database passwoPSQL:  
```sh
kubectl create secret generic db-credentials \
  --from-literal=APP_ROLE_PASSWORD='your-secure-password' \
  --from-literal=APP_USER_PASSWORD='your-secure-password' \
  -n your-namespace
```

---

### **3️⃣ Deploy the Helm Chart**
Run the following command to deploy the Helm chart:  
```sh
helm install db-init ./helm-db-init --namespace your-namespace
```

To **upgrade** or reapply:
```sh
helm upgrade --install db-init ./helm-db-init --namespace your-namespace
```

---

### **4️⃣ Verify Deployment**
Check logs to confirm execution:  
```sh
kubectl logs -l job-name=db-init-job -n your-namespace
```

Confirm roles and grants in PostgreSQL:  
```sql
SELECT rolname FROM pg_roles;  
SELECT grantee, privilege_type FROM information_schema.role_table_grants WHERE grantee = 'app_role';
```

---

### **⚠️ Important: RDS Superuser Limitation**
Amazon RDS for PostgreSQL **does not allow creating SUPERUSER roles**. Instead, you should create a login role with `rds_superuser` privileges after logging in with the default user.

#### **Create a New Admin Role with Elevated Privileges**
```sql
CREATE ROLE my_admin WITH LOGIN PASSWORD 'securepassword';
GRANT rds_superuser TO my_admin;
```
This allows `my_admin` to:
- Create and manage roles.
- Grant permissions on schemas and tables.
- Manage PostgreSQL extensions.

#### **Verify the Role**
```sql
SELECT rolname, rolsuper, rolcreaterole, rolcreatedb FROM pg_roles WHERE rolname = 'my_admin';
```
This should show:
- **rolsuper = FALSE** (since RDS blocks SUPERUSER).
- **rolcreaterole = TRUE** (can create and manage roles).
- **rolcreatedb = TRUE** (can create databases).

Use this approach to ensure proper privilege management in your RDS setup.

---

## **🔄 Uninstalling**
To remove the deployment:  
```sh
helm uninstall db-init --namespace your-namespace
```
To delete Secrets:  
```sh
kubectl delete secret db-credentials -n your-namespace
```

---

## **🛠️ Customization**
Modify `values.yaml` to customize roles, users, and grants:  
```yaml
sqlScripts:
  roles: |
    DO $$ 
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'custom_role') THEN
            CREATE ROLE custom_role WITH LOGIN PASSWORD current_setting('custom_role_password');
        END IF;
    END $$;
```

---

## **📌 Next Steps**
- 🔹 **Integrate with CI/CD** to run after database migrations  
- 🔹 **Automate Role Expiry & Rotation** using CronJobs  
- 🔹 **Extend for Multi-DB Environments**  

---

## **📄 License**
This project is licensed under the **MIT License**.  

---

## **🤝 Contributing**
Feel free to fork this repo, submit PRs, or suggest improvements!  
