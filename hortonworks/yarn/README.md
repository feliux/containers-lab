# Gestión de clúster

Un tema importante en la gestión de un clúster es gestionar los recursos de éste para que todos los usuarios puedan ejecutar sus trabajos, por lo tanto, se propone un ejemplo del fichero `capacity-scheduler.xml` donde se implementa la siguiente estructura de colas, con las características que se indican a continuación. 

*NOTA: se incluirán en el fichero todas las propiedades que se solicitan, aún cuando el valor por defecto sea el que se deba configurar.*

La estructura de colas a implementar es:

- Todas las colas estarán activas excepto la cola socialnetworks que se encontrará parada.

- El número máximo de aplicaciones concurrentes en el clúster son 999.

- Todos los trabajos del grupo direccion irán siempre a la cola online y no se les permitirá que los envíen a otra cola.

- Colas:

    - **root**

        - **develop** Capacidad: 25; Máxima Capacidad: 50; User-limit: 2; Administrador cola y jobs: javier; Usuarios cola: javier y el grupo programadores.

        - **marketing** Capacidad: 65; Máxima Capacidad: 100

        - **online** Capacidad: 50; Máxima Capacidad: 70; Límite capacidad usuario: La capacidad de la cola; Administrador cola: maria; Administrador jobs: susana e isabel; Usuarios cola: grupo comerciales

        - **socialnetworks** Capacidad: 25; Máxima Capacidad: 50; Administrador cola y jobs: grupo redes; Usuarios cola: grupo redes.

        - **other** Capacidad: 25; Máxima Capacidad: La misma que la capacidad; Máximo aplicaciones: 40; Administrador cola: juan; Administrador jobs: miguel; Usuarios cola: miguel y juan y grupo comerciales (marketing).

        - **default** Capacidad: 10; Máxima Capacidad: 30; Límite capacidad usuario: El doble de la capacidad de la cola; Porcentaje mínimo usuario: 25

Además de configurar directamente el fichero `capacity-scheduler.xml` también es posible realizar la configuración de las colas desde **Ambari**.
