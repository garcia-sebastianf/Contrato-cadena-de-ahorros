# Contrato-cadena-de-ahorros
Este proyecto crea una página Web3 con una interfaz gráfica que permite a los usuarios interactuar visualmente con la red de prueba de Ethereum (Sepolia). La lógica del contrato en el backend automatiza un método de ahorro conocido como cadenas, asegurando que las personas puedan ahorrar sin riesgo de perder su dinero. 

# Lógica general del contrato
- El contrato debe ser creado para esperar el pago de los participantes en intervalos regulares, por ejemplo, mensualmente. La duración total del plan de ahorro dependerá del número de participantes, y esta duración se fijará al inicio y no cambiará incluso si algunos usuarios quedan excluidos.<br>

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
- Justo al finalizar el día de pago, se enviará una notificación a uno de los usuarios, seleccionado según el orden de la lista, informándole del monto que recibirá al final del plan y del nuevo valor de las cuotas que deberá pagar en adelante. Esto dependerá del número de usuarios que cumplan con sus pagos.

