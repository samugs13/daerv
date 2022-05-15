<img src="https://user-images.githubusercontent.com/78796980/168422761-4be1d1b5-c065-4f44-86d7-44d346971897.png" width="215" height="100">


# Despliegue Automatizado de Escenarios de Red Virtualizados


                            ███████       ██     ████████ ███████   ██      ██
                           ░██░░░░██     ████   ░██░░░░░ ░██░░░░██ ░██     ░██
                           ░██    ░██   ██░░██  ░██      ░██   ░██ ░██     ░██
                           ░██    ░██  ██  ░░██ ░███████ ░███████  ░░██    ██
                           ░██    ░██ ██████████░██░░░░  ░██░░░██   ░░██  ██
                           ░██    ██ ░██░░░░░░██░██      ░██  ░░██   ░░████
                           ░███████  ░██     ░██░████████░██   ░░██   ░░██
                           ░░░░░░░   ░░      ░░ ░░░░░░░░ ░░     ░░     ░░


Este repositorio contiene el código desarrollado para mi Trabajo de Fin de Grado "Desarrollo de una herramienta para el despliegue automatizado de escenarios de red virtualizados aplicables a plataformas CyberRange".

## Descripción :page_facing_up:
El objetivo de este trabajo es realizar despliegues de red heterogéneos virtualizados, aplicables a plataformas CyberRange para la formación y entrenamiento en el campo de la ciberseguridad. Este despliegue se ha llevado a cabo empleando la tecnología Terraform, con providers basados en Cloud (en concreto Google Cloud Platform) y la tecnología de virtualización ligera Docker para el aprovisionamiento de la infraestructura desplegada en la nube.

## Estructura del proyecto :open_file_folder:

## Dependencias :bookmark:
  - [Terraform](https://www.terraform.io/downloads)
  - [gcloud CLI](https://cloud.google.com/sdk/docs/install)

## Pre-requisitios :hourglass_flowing_sand:
  - Clonar el repositorio en el directorio de trabajo con el siguiente comando: `git clone https://github.com/samugs13/DAERV`
  - Disponer de una cuenta en Google Cloud Platform
  - Crear un proyecto de Google Cloud

Una vez tengamos creada una cuenta y un proyecto en ella, debemos [habilitar la API de Google Compute Engine para nuestro proyecto en la consola de GCP](https://console.developers.google.com/apis/library/compute.googleapis.com).

## Preparación del entorno :wrench:
En primer lugar, hay que autenticarse con GCP. Para ello, basta con ejecutar `gcloud auth application-default login` en la terminal. Esto nos dirigirá a una página donde podremos iniciar sesión con nuestra cuenta de Google para permitir el acceso a nuestros datos de GCP.

Para poder realizar peticiones desde Terraform a la API de GCP, es necesario autenticarse para así probar que somos quien están realizando esas peticiones. Hay varias formas de realizar esta autenticación. Una de ellas es mediante las Cuentas de Servicio de Google Cloud, para la cual hay que seguir los siguientes pasos:

1. En el apartado de [Cuentas de Servicio](https://console.cloud.google.com/iam-admin/serviceaccounts) de la consola de Google Cloud debemos elegir una cuenta existente, o crear una nueva. A la hora de crearla hay que tener en cuenta que es necesario asignar permisos de edición.

2. En la sección de claves, debemos generar una clave y descargarla en formato JSON, ponerle un nombre del que nos vayamos a acordar y almacenarla en un lugar seguro. 

3. Para proporcionarle la clave descargada a Terraform, lo haremos mediante la variable de entorno `GOOGLE_APPLICATION_CREDENTIALS`, asignándole como valor el de la ruta al archivo con la clave:
```
export GOOGLE_APPLICATION_CREDENTIALS={{path}}
```
> Para que las credenciales se guarden entre sesiones, es necesario añadir esta línea a un fichero de inicio como bash_profile o bashrc. Si esto no es de tu gusto, una opción alternativa a la variable de entorno sería proporcionar a Terraform el path a la clave en la configuración del provider, dentro del fichero `main.tf`.

## Arranque del entorno :rocket:
## Escenarios de red :computer:
## Autor :art:
[Samuel García Sánchez](https://github.com/samugs13)





