# Contrato-cadena-de-ahorros
Este proyecto crea una página Web3 con una interfaz gráfica que permite a los usuarios interactuar visualmente con la red de prueba de Ethereum (Sepolia). La lógica del contrato en el backend automatiza un método de ahorro conocido como cadenas, asegurando que las personas puedan ahorrar sin riesgo de perder su dinero. El código del contrato está ubicado en backend/contracts/ContratoCadena.sol

# Lógica general del contrato
- El contrato debe ser creado para esperar el pago de los participantes en intervalos regulares, por ejemplo, mensualmente. La duración total del plan de ahorro dependerá del número de participantes, y esta duración se fijará al inicio y no cambiará incluso si algunos usuarios quedan excluidos.<br><br>

$$
NumeroMesesCadena = NumeroUsuarios
$$

<br>

- El contrato establece fechas límite para los pagos de los usuarios. Un día antes de la fecha límite, se enviará una alerta a los usuarios como recordatorio para realizar el pago. Si un usuario no realiza su pago antes de la fecha límite, su billetera será excluida del contrato y quedará excluido de la cadena.<br><br><br>
  

   > Ejemplo: Si el plazo límite para el pago es el 15 de mayo de 2024 a las 23:59, se enviará un recordatorio
   > el día 14 de mayo a las 00:01. A los usuarios que no paguen antes de la fecha límite, se les notificará que
   > fueron excluidos de la cadena. Además, se les informará del monto que les corresponderá al final del plan,
   > el cual será equivalente a la cantidad que hayan consignado hasta ese momento.
   
   <br>

- Justo al finalizar el día de pago, se enviará una notificación a uno de los usuarios, seleccionado según el orden de la lista, informándole del monto que recibirá al final el plan y del nuevo valor de las cuotas que deberá pagar en adelante. Esto dependerá del número de usuarios que cumplan con sus pagos.

>Ejemplos de casos ideales y realistas.
>En un escenario ideal, si participan 10 personas con una cuota inicial de 50 mil pesos, el monto asignado a un usuario al final del plan sería:

$$
MontoAsignadoUsuario = 10*50mil = 500mil
$$

>Esto implica que el usuario deberá cumplir con una cuota mensual de 50mil pesos para completar el monto asignado.
>
>En un escenario más realista, si solo ocho personas cumplen con sus pagos, el monto asignado a un usuario sería:

$$
MontoAsignadoUsuario = 8*50mil = 400mil 
$$

>En este caso, la nueva cuota del usuario se calculará para garantizar que al final del plan pague el monto asignado:

$$
NuevoValorCuota = \frac{MontoAsignadoUsuario - ValorCuotasPagadas}{MesesRestantes}
$$

>Al actualizar el valor de las cuotas futuras de un usuario, se afectará el valor asignado a los usuarios en los meses posteriores. Esta fórmula se aplicará de forma recursiva para
>calcular las nuevas cuotas de los demás usuarios.
>
>En este ejemplo, el usuario ya habría pagado una primera cuota de 50mil, pero se le asigna un monto de solo 400mil, por lo que según la fórmula anteriore su nuevo monto será:

$$
NuevoValorCuota = (400mil - 50mil*(1))/(10-1)
$$

$$
NuevoValorCuota = 38.889 mil (Aproximado)
$$

>Los meses restantes en este caso son de 9, ya que se cumplió el primer mes de la cadena.
>
>Haciendo cuentas, con la actualización de la cuota del usuario, el monto que deberá pagar finalizando la cadena será de:

$$
  MontoAPagar = 50mil*(1)+38.889mil*(10-1) ≈ 400mil
$$

>Por lo que con la actualización de su cuota el usuario terminará pagando el mismo monto que se le asignará finalizando la cadena.

# Modelo de negocio:

El dueño del contrato siempre será el dueño de la aplicación, con el objetivo de prevenir que personas inescrupulosas creen cadenas de forma indiscriminada para vaciar los fondos. Cuando un usuario desee desplegar un contrato, deberá pagar un pequeño monto adicional al requerido por la red de Ethereum. Esta tarifa adicional será asignada a la billetera del dueño de la aplicación. Además, el usuario que haya desplegado el contrato tendrá la capacidad de agregar usuarios a la cadena del contrato dentro de un tiempo límite establecido antes de que el contrato se active de forma automática. Sin embargo, para que estos usuarios sean efectivamente incorporados, deberán pagar una pequeña tarifa adicional. Este monto adicional se transferirá a la billetera del usuario que desplegó el contrato, con el fin de incentivar la creación de nuevas cadenas y el crecimiento de la comunidad. 



