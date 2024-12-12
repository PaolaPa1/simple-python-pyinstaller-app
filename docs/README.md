# Entregable 3
## _Instrucciones de Despligue_

Vamos a ver los pasos para poder replicar el despligue del pipeline desde _simple-python-pyinstaller-app_

## Paso 1
Abrimos [el siguiente repositorio](https://github.com/jenkins-docs/simple-python-pyinstaller-app)
A la derecha encontramos "fork". Hacemos clic en la opción y procedemos a crear el fork en nuestra cuenta de github. Podemos elegir el nombre que queramos. Una vez creado accedemos a nuestra cuenta y buscamos en los repositorios. Abrimos el fork que acabamos de crear y en la opción "Setting" buscamos "Default branch". Cambiamos master en _main_. 
Esto porque en la configuración del pipeline vamos a poner */main. Se puede usar el nombre que se quiera estando cuidado con la configuración sucesiva del pipeline. 

## Paso 2
En GitHub desktop clonamos el repositorio y abrimoslo con Visual Studio Code. Creamos la carpeta _docs_ donde vamos a poner el Dockerfile y el archivo Terraform.

## Paso 3
Creamos el dockerfile para la imagen personalizada basada en Jenkins para asegurar la integración con Docker. Nos aseguramos de dar los permisos necesarios para instalar y actualizar paquetes. Creamos el repositorio para Docker e instalamos el plugin de Jenkins.
En la terminal ejecutamos:
```sh
cd docs
docker build -t myjenkins_bo .
docker image ls 
```
El ultimo comando para asegurarnos que la imagen se haya creado correctamente

## Paso 4
Creamos las configuraciones Terraform para los contenedores _DockerInDocker_ y _BlueOcean_
En esta parte lo que hay que tener cuidado es la forma del file, es decir que no haya huecos o cosas que faltan porque esto va a causar errores. Lo digo porque me ha pasado en la configuracion de variables que dejé un espacio entre = y fallaba sin saber porque. Muy importante también tener claros los nombres que usamos para que todo se connecte correctamente
Una vez creadolos en la terminal ejecutamos
```sh
terraform init
terraform apply 
```
Para averiguar que todo funcione:
```sh
docker ps 
```
que nos muestra los contenedores creados, aseguramos que estén en UP
```sh
docker network inspect red_jenkins 
```
que nos muestra si nuestros contenedores estan conectados en la red que queremos. Si por si casualidad esto falla ejecutamos 
```sh
docker network ls 
```
para controlar que la red se haya creado correctamente 

## Paso 5
Ahora abrimos la pagina web localhost:8080 y tenemos que acceder a Jenkins con la password que se ha creado automaticamente en los logs. 
Volvemos a VS Code y ejecutamos 
```sh
docker exec -it docker /bin/bash
```
si falla ponemos _sh_ en lugar de _bash_

Una vez dentro del contenedor ejecutamos 
```sh
cat var/jenkins_home/secrets/initialadminpassword
```

esto nos restituye la password. Ahora simplemente seguimos los pasos que nos da Jenkins, instalando los paquetes que nos aconseja.

## Paso 6
Una vez dentro de Jenkins creamos nuestra Pipeline. A la izqueirda clicamos en NewItem, le damos el nombre que queremos y ponemos pipeline. En la configuracion buscamos la parte _pipeline_ y seleccionamos _Pipeline Script from SCM_. 
En SCM ponemos Git. Nos vamos en nuestra cuenta de GitHub en nuestro repositorio y clicamos el boton verde para copiar el URL, que ponemos donde nos lo pide Jenkins. 
En la opcion de _Branch_ cambiamos _*/master_ con _*/main_
Guardamos.

Ahora clicamos _Build Now_ y esperamos que Jenkins cree los artefactos. Una vez terminado los encontramos en Status. 
También se puede usar Blue Ocean. Los pasos son muy similares.
Abrimos BlueOcean y clicamos la pipiline que queremos. Elegimos la Build y clicamos. Una vez dentro a la derecha vamos a encontrar Artifacts.

## Consideraciones y Errores Frecuentes
En el repositorio GitHub solo hay 2 (circa) commit. Esto porque he borrado el repositorio precedente porque compilando en Jenkins me salìa este error:
```sh
   ERROR: Error cloning remote repo 'origin'
   ...
       Caused by: java.io.IOException: CreateProcess error=5, Access is denied
```
Busqué una solucion pero sin encontrarla asì que lo unico que me quedaba era borrar todo e intentar todo desde el inicio. De hecho el mismo codigo que me daba ese error no ha vuelto a darmelo. Probablemente se había guardado algún archivo corrompido que impedía el funcionamiento correcto y que no obstante el _terraform destroy_ permanecía.

Otro error que me ha salido es:
```sh
error during connect: Post "https://jenkinsDocker:2376/v1.47/images/create?fromImage=python&tag=3.12.0-alpine3.18": tls: failed to verify certificate: x509: certificate is valid for 488112ec15a3, docker, localhost, not jenkinsDocker
```
Esto lo he resuelto simplemente dandole el nombre _docker_ a mi contenedor. La variable se llamaba jenkinsDocker en todas las partes del codigo en la que ahora se encuentra _docker_.

