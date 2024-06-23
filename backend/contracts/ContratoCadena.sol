/***
 *        _____                    _                                                  
 *       / ____|                  | |                                                 
 *      | |     _ __ ___  __ _  __| | ___    _ __   ___  _ __                         
 *      | |    | '__/ _ \/ _` |/ _` |/ _ \  | '_ \ / _ \| '__|                        
 *      | |____| | |  __/ (_| | (_| | (_) | | |_) | (_) | |                           
 *       \_____|_|  \___|\__,_|\__,_|\___/  | .__/ \___/|_|                           
 *                                          | |                                      
 *       _____      _               _   _   |_|          _____                __      
 *      / ____|    | |             | | (_) /_/          / ____|              /_/      
 *     | (___   ___| |__   __ _ ___| |_ _  __ _ _ __   | |  __  __ _ _ __ ___ _  __ _ 
 *      \___ \ / _ \ '_ \ / _` / __| __| |/ _` | '_ \  | | |_ |/ _` | '__/ __| |/ _` |
 *      ____) |  __/ |_) | (_| \__ \ |_| | (_| | | | | | |__| | (_| | | | (__| | (_| |
 *     |_____/ \___|_.__/ \__,_|___/\__|_|\__,_|_| |_|  \_____|\__,_|_|  \___|_|\__,_|
 *                                                                                    
 *                                                                                    
 */

// SPDX-License-Identifier:  GPL-3.0

pragma solidity ^0.8.24;

contract ContratoCadena {

    //Estructura para guardar los datos de cada usuario
    struct Usuario {
        address direccionUsuario;    //Dirección de la billetera del usuario.
        uint valorCuota;             //Cuota que el usuario debe pagar mensualmente.
        uint montoAsignado;          //El dinero que se le dará al usuario al finalizar la cadena.
        uint BalanceUsuario;         //El dinero que el usuario ha aportado hasta el momento.
        bool estadoUsuario;          //Determina si el usuario pertenece a la cadena.
        bool estadoUsuarioExpulsion; //Determina si el usuario ha sino o no expulsado de la cadena por incumplir 
                                     //con su cuota.
        bool EstadoPagoCuota;        //Determina si el usuario ya ha pagado su cuota.
        bool EstadoMontoAsignado;    //Determina si el monto ya se le ha asignado al usuario.
    }
    
    uint private valorCuotaInicial;
    uint private montoAsignadoInicial;
    uint private BalanceUsuarioInicial;
    bool private estadoUsuarioInicial;
    bool private estadoUsuarioExpulsionInicial;
    bool private EstadoPagoCuotaInicial; 
    bool private EstadoMontoAsignadoInicial;

    mapping(uint => Usuario) public Usuarios;  //Mapeo para establecer los usuarios y sus datos asociados.

    uint private income; // Registra el ingreso del contrato

    uint private MontoAPagarDuenoCadena;   // Valor que debe pagar el dueño de la cadena para poder agregar usuarios.
    uint private MontoAPagarUsuario;       // Valor que debe pagar cada usuario para ser incluidos en la cadena. 
    uint private DepositoDeGarantia;       // Pago que se le devuelve a el usuario en caso de no poder dar inicio
                                           // a la cadena. 
    bool private PagoRealizadoDuenoCadena; // Bandera que indica que el pago haya sido realizado por el dueño 
                                           // de la cadena. 
    bool private UsuarioValido;            // El usuario es valido solamente si es agregado por el dueno de la 
                                           // cadena.
    bool private CadenaIniciada;           // Bandera que indica que el dueno de la cadena ya ha dado inicio
                                           // a la cadena. 
    uint private NumeroUsuarios;           // Mantiene registro del numero de usuarios que han sido agregados
                                           // a la lista de participantes por el dueno de la cadena.
    uint private NumeroUsuariosActivos;    // Mantiene registro del numero de usuarios que han sido agregados a la cadena.
    bool private UsuarioRepetido;          // Bandera que indica que los usuarios no se encuentren repetidos.
    uint private IndiceUsuario;            // Posicion de usuario dentro del contrato.  
    uint private CiclosDePagoTranscurridos; //Toma la cuenta del numero de ciclos de pago que ya han transcurrido. 
        
    address payable owner; // Dueño de la aplicación (Recibe ganancias por cada cadena iniciada, modelo de negocio).
    address payable public DuenoCadena; // Persona que inicia la cadena (Dueño de la cadena)
    address payable contrato; //Direccion para depositar fondo de garantia en el contrato.

    //Guardar balances de los diferentes participantes en la cadena. 
    int  ownerContractBalance; //Saldo del dueño de la aplicacion dentro de este contrato
    int  DuenoCadenaContractBalance; //Saldo del dueno de la cadena dentro de este contrato
    uint BalanceDepositoDeGarantia;
    uint BalanceMontoAsignadoUsuario;
        
    //Eventos para depuración
    event MensajeAUsuario(string mensaje);
    event Depuracion(string mensaje1, uint , string mensaje2, uint);
    event LogString(string mensaje);
    event BalanceAsignadoUsuario(uint BalanceUsuario);

    uint IncrementoMes;
        
    constructor() {
        owner = payable(0xAbc5761A3551a3976d60E483A9b5A83825b6d1f3); // Asignar dirección del propietario
                                                                     // de la aplicación            
        DuenoCadena = payable(0x0);                 // Asignar la dirección del dueño de la cadena
        contrato = payable(address(this));          // Asignar la dirección del propio contrato.
        MontoAPagarDuenoCadena = 200000000000;      // El monto es de 0.0002  Finney, 0.0000002  ETH, 200 Gwei                               
        MontoAPagarUsuario     = 40000000000;       // El monto es de 0.00004 Finney, 0.00000004 ETH, 40 Gwei
        DepositoDeGarantia     = 40000000000;       // El monto es de 0.00004 Finney, 0.00000004 ETH, 40 Gwei
 
        PagoRealizadoDuenoCadena = false;
        CadenaIniciada = false;
        UsuarioRepetido = false;
        NumeroUsuarios = 0;
        NumeroUsuariosActivos = 0;
        IndiceUsuario = 0;
        CiclosDePagoTranscurridos = 0;

        //Se definen las condiciones iniciales de la cadena. 
        valorCuotaInicial = 5000000000;  // 5 Gwei
        montoAsignadoInicial = 0; //Ya que ningun usuario ha pagado en esta etapa
        BalanceUsuarioInicial = 0;
        estadoUsuarioInicial = false; //Aunque el desplegador agregue usuarios, su estado será falso 
                                      //hasta que realicen el pago para pertenecer a la cadena.
        estadoUsuarioExpulsionInicial = false;
        EstadoPagoCuotaInicial = false;
        EstadoMontoAsignadoInicial = false; 

        UsuarioValido = false;    
        ownerContractBalance = 0;
        DuenoCadenaContractBalance = 0;
        BalanceDepositoDeGarantia = 0;
        BalanceMontoAsignadoUsuario = 0;

        IncrementoMes = 0;
    }

//----------------- Re restringen funciones a los diferentes tipos de usuarios --------------------------//

    modifier soloDuenoCadena () { //Restringe funciones a todos los participantes excepto para el dueño de la cadena.
        require(msg.sender == DuenoCadena && PagoRealizadoDuenoCadena == true, "Solo el dueno de la cadena puede realizar esta accion");
        _;
    }

//-----------------Funciones para el manejo de transacciones  -----------------------------------------//

    //Recibe el pago del dueno de la cadena para poder habilitarle la función de agregar usuarios.
    function RecibirPagoDuenoCadena () public payable {

        DuenoCadena = payable(msg.sender);

        if(PagoRealizadoDuenoCadena == false){

            if(msg.value > MontoAPagarDuenoCadena){

                emit MensajeAUsuario("Su pago ha sido realizado con exito y ahora es el dueno de la cadena\
                                    , se le devolvera el cambio a su cuenta");
                DuenoCadena.transfer(msg.value - MontoAPagarDuenoCadena);
                DuenoCadenaContractBalance -= int(MontoAPagarDuenoCadena);

                owner.transfer(MontoAPagarDuenoCadena-DepositoDeGarantia);
                ownerContractBalance += int(MontoAPagarDuenoCadena)-int(DepositoDeGarantia);

                //contrato.transfer(DepositoDeGarantia);
                BalanceDepositoDeGarantia = DepositoDeGarantia;
                PagoRealizadoDuenoCadena = true;

            }else if(msg.value < MontoAPagarDuenoCadena){

                emit MensajeAUsuario("Su pago es menor al establecido, el activo sera revertido");
                DuenoCadena.transfer(msg.value);

                PagoRealizadoDuenoCadena = false;

            }else if(msg.value == MontoAPagarDuenoCadena){

                emit MensajeAUsuario("Su pago ha sido realizado con exito y ahora es el dueno de la cadena");
                owner.transfer(msg.value-DepositoDeGarantia);
                DuenoCadenaContractBalance -= int(msg.value);
                ownerContractBalance += int(msg.value)- int(DepositoDeGarantia);

                //contrato.transfer(DepositoDeGarantia);
                BalanceDepositoDeGarantia = DepositoDeGarantia;
                PagoRealizadoDuenoCadena = true;
            }
        }else{
            emit MensajeAUsuario("Ya se ha realizado el pago para habilitar el inicio de la cadena");
            DuenoCadena.transfer(msg.value);
        }
    }

//---------------------------------------------------------------------------------------------------//

    //Función para que el dueño de la cadena agregue una nueva dirección de usuario.
    function AgregarDireccionesDeUsuarios(address NuevaDireccion) public soloDuenoCadena{
            
        if(CadenaIniciada == false){
            if(PagoRealizadoDuenoCadena == true) {

                for(uint i = 0 ; i < NumeroUsuarios; i++){
                    if(Usuarios[i].direccionUsuario == NuevaDireccion){
                        UsuarioRepetido = true;
                    }
                }

                if(UsuarioRepetido == false){
                    Usuarios[IndiceUsuario] = Usuario({
                        direccionUsuario: NuevaDireccion,
                        valorCuota: valorCuotaInicial,
                        montoAsignado: montoAsignadoInicial,
                        BalanceUsuario: BalanceUsuarioInicial,
                        estadoUsuario: estadoUsuarioInicial,
                        estadoUsuarioExpulsion: estadoUsuarioExpulsionInicial,
                        EstadoPagoCuota: EstadoPagoCuotaInicial,
                        EstadoMontoAsignado: EstadoMontoAsignadoInicial
                    });

                    NumeroUsuarios++;
                    IndiceUsuario++;
                    emit MensajeAUsuario("El usuario ha sido agregado correctamente");
                }else{
                    emit MensajeAUsuario("Este usuario ya ha sido agregado");
                    //Restablecemos el valor de la bandera, ya que el usuario repetido no fue agregado.
                    UsuarioRepetido = false;
                }
            }else{
                emit MensajeAUsuario("Debe de realizar el pago antes de poder agregar usuarios");
            }
        }else{
            emit MensajeAUsuario("No puede agregar mas integrantes porque ya ha dado inicio a la cadena");
        }
    }

    //Función para que el desplegador del contrato inicie la cadena de ahorro.
    function IniciarContrato() public soloDuenoCadena{
        //El número de usuarios debe ser al menos de dos personas para poder iniciar la cadena. 
        if(NumeroUsuariosActivos >= 2){
            if(CadenaIniciada == false){
                CadenaIniciada = true; 
                //Al iniciar la cadena, el deposito se envia al dueño de la aplicación, al ya no ser necesario.
                owner.transfer(DepositoDeGarantia);
                ownerContractBalance += int(DepositoDeGarantia);
                BalanceDepositoDeGarantia = 0;
            }else{
                emit MensajeAUsuario("Ya se ha dado inicio a la cadena");
            }
        }else{
            emit MensajeAUsuario("El numero de usuarios activos debe ser almenos de dos para iniciar la cadena,\
                                  el monto consignado va a ser retornado de forma inmediata al unico usuario\
                                  activo en la cadena.");
            for (uint i = 0 ; i < NumeroUsuarios; i++){ //Con esta funcion se busca al unico usuario activo en la
                                                        //cadena que realizó el pago y se le retorna el monto 
                                                        //consignado.
                if(Usuarios[i].estadoUsuario == true){
                    //Se realiza el pago inmediato al único usuario activo en la cadena
                    payable(Usuarios[i].direccionUsuario).transfer(DepositoDeGarantia);
                    BalanceDepositoDeGarantia = 0;
                }
            }
        }
    }

    //Función para establecer pago y actualizar cuotas.
    function ActualizarCuota () public  {
        require(CadenaIniciada == true,"La cadena no ha sido iniciada");

        //Establecer de nuevo el pago de la cuota y expulsar a los usuarios incumplidos
        ReiniciarEstadoCuotas();
        emit BalanceAsignadoUsuario(BalanceMontoAsignadoUsuario);
        CalcularCuota();
        BalanceMontoAsignadoUsuario = 0; 
    }

    function ReiniciarEstadoCuotas () private{
        uint m;
        m = 0;
        while(m < NumeroUsuarios){
            //Expulsar a los usuarios que no realizaron su pago
            if(Usuarios[m].estadoUsuario == true && Usuarios[m].EstadoPagoCuota == false && Usuarios[m].estadoUsuarioExpulsion == false){
                emit MensajeAUsuario("Su plazo para el pago de la cuota ha vencido. Como resultado, sera\
                                      inhabilitado de la cadena de ahorros y no podra participar ni realizar\
                                      mas pagos. Su saldo en la cadena se le devolvera al finalizar la misma"); 
                Usuarios[m].estadoUsuarioExpulsion = true; // Se inhabilita al usuario de la cadena.
                //(PROBLEMA PARA LA SEGUNDA ENTREGA FRONTEND)
                //IMPORTANTE: Se le debe informar al usuario de cual será el monto que se le dará al final de la cadena apenas se inhabilite,
            }else{
                Usuarios[m].EstadoPagoCuota = false; //Restablece el estado del pago de la cuota para futuros pagos.
            }
            m++;
        }
    }

    function CalcularCuota () private{
        uint PeriodosTiempoRestantes;
        PeriodosTiempoRestantes = 0;

        int PagoRestante;
        PagoRestante = 0;
        
        while(IncrementoMes < NumeroUsuarios){
            if(Usuarios[IncrementoMes].estadoUsuario == true && Usuarios[IncrementoMes].EstadoMontoAsignado == false ){
                CiclosDePagoTranscurridos++;
                //Calculamos el nuevo valor de la cuota del usuario.
                emit Depuracion("NumeroUsuariosActivos",NumeroUsuariosActivos,"PeriodosTranscurridos",CiclosDePagoTranscurridos);
                if(CiclosDePagoTranscurridos < NumeroUsuariosActivos){ 
                    //Establecemos el monto asignado que le corresponde al usuario y recalculamos su cuota futura.
                    Usuarios[IncrementoMes].montoAsignado = BalanceMontoAsignadoUsuario; //Depende de la cantidad de dinero 
                                                                             //que se haya pagado entre todos los usuarios
                    Usuarios[IncrementoMes].EstadoMontoAsignado = true; //Esto porque el dinero que se le pagará al usuario finalizando
                                                         // la cadena ya se le ha asignado
                    PeriodosTiempoRestantes = NumeroUsuariosActivos - CiclosDePagoTranscurridos;
                    PagoRestante = int(BalanceMontoAsignadoUsuario)-int(Usuarios[IncrementoMes].BalanceUsuario);

                    if(PagoRestante > 0){
                        Usuarios[IncrementoMes].valorCuota = (BalanceMontoAsignadoUsuario-Usuarios[IncrementoMes].BalanceUsuario)/(PeriodosTiempoRestantes);
                    }else{ 
                        Usuarios[IncrementoMes].valorCuota = 0; //Ya que lo que pagó es mayor a lo que se le asignó.
                    }
                }else{
                    //La ejecución del contrato ha finalizado y ahora tengo re reiniciar todos los valores de la 
                    //estructura.
                    emit MensajeAUsuario("Aqui se supone que terminan los periodos de tiempo");
                    RepartirPagos();
                    ReestablecerValoresUsuarios(); 
                }
                IncrementoMes++;
                return;
            }
            IncrementoMes++;
        }
    }

    //Pagar a todos los integrantes al finalizar el contrato
    function RepartirPagos () private {
        for(uint i = 0; i < NumeroUsuarios; i++){
            //Reparto el valor del balance a todos los usuarios
            require(address(this).balance >= Usuarios[i].BalanceUsuario, "El contrato no tiene suficiente saldo");
            if(Usuarios[i].BalanceUsuario > 0 && Usuarios[i].estadoUsuario == true){
                payable(Usuarios[i].direccionUsuario).transfer(Usuarios[i].BalanceUsuario);
            }
        }
    }

    //Restablecer valores de los usuarios al finalizar el contrato
    function ReestablecerValoresUsuarios () private{
        for(uint i = 0; i < NumeroUsuarios; i++){
            Usuarios[i] = Usuario(0x0000000000000000000000000000000000000000,
                                  valorCuotaInicial,
                                  montoAsignadoInicial,
                                  BalanceUsuarioInicial,
                                  estadoUsuarioInicial,
                                  estadoUsuarioExpulsionInicial,
                                  EstadoPagoCuotaInicial,
                                  EstadoMontoAsignadoInicial); 
        }

        CadenaIniciada = false;
        CiclosDePagoTranscurridos = 0;
        PagoRealizadoDuenoCadena = false;
        CadenaIniciada = false;
        UsuarioRepetido = false;
        NumeroUsuarios = 0;
        NumeroUsuariosActivos = 0;
        IndiceUsuario = 0;
        CiclosDePagoTranscurridos = 0;
        UsuarioValido = false;    
        ownerContractBalance = 0;
        DuenoCadenaContractBalance = 0;
        BalanceDepositoDeGarantia = 0;
        BalanceMontoAsignadoUsuario = 0;
        IncrementoMes = 0;
    }

    //Función para activar a los usuarios en la cadena al momento que paguen.
    function RecibirIngresosDeParticipacionUsuarios () public payable {
        require(CadenaIniciada == false,"Ya no se aceptan pagos para participar en la cadena,\
                                        ya que esta ha sido iniciada y su plazo de pago ha vencido.");

        for (uint i = 0; i < NumeroUsuarios; i++){

            if(msg.sender == Usuarios[i].direccionUsuario){
                if(Usuarios[i].estadoUsuario == false){
                    if(msg.value > MontoAPagarUsuario){

                        Usuarios[i].estadoUsuario = true; //Se activa el usuario en el momento en el que realice el pago.
                        NumeroUsuariosActivos++;
                        emit MensajeAUsuario("Su pago ha sido procesado exitosamente y ha sido agregado a la cadena\
                                              ,se le devolvera el cambio a su cuenta");
                        payable(msg.sender).transfer(msg.value - MontoAPagarUsuario); //Se devuelve el cambio al usuario
                                                                               //que realiza el pago
                        DuenoCadena.transfer(MontoAPagarUsuario); //El pago se envia al usuario que despliega el contrato.
                        DuenoCadenaContractBalance += int(MontoAPagarUsuario); 

                    }else if(msg.value < MontoAPagarUsuario){

                        emit MensajeAUsuario("Error al procesar su pago: el monto ingresado es menor al establecido.\
                                              Su pago sera revertido");
                        payable(msg.sender).transfer(msg.value);

                    }else if(msg.value == MontoAPagarUsuario){

                        Usuarios[i].estadoUsuario = true; //Se activa el usuario en el momento en el que realice el pago.
                        NumeroUsuariosActivos++;
                        emit MensajeAUsuario("Su pago ha sido procesado exitosamente y ha sido agregado a la cadena");
                        DuenoCadena.transfer(msg.value);
                        DuenoCadenaContractBalance += int(msg.value);
                    }
                    
                }else{
                    emit MensajeAUsuario("Usted ya ha realizado el pago anteriormente, su pago sera revertido.");
                    payable(msg.sender).transfer(msg.value);
                }

            UsuarioValido = true; //El usuario que quiere hacer el pago es valido solo si ya ha sido agregado
                                  //por el desplegador del contrato.

            }
        }

        if(UsuarioValido == false){
            emit MensajeAUsuario("Su direccion de usuario no ha sido agregada por el desplegador del contrato.\
                                  Por lo tanto, su pago ha sido denegado. Si desea formar parte de este contrato,\
                                  por favor, pongase en contacto con el desplegador del contrato para que lo\
                                  agregue a esta cadena.");
            payable(msg.sender).transfer(msg.value); //Se revierte el pago al usuario no valido.
        }    
        UsuarioValido = false; 
    }

    //Función para que los usuarios consignen sus cuotas en la cadena.
    function RecibirIngresosCuotasUsuarios () public payable {

        require(CadenaIniciada == true,"El contrato no ha sido desplegado");

        for(uint i = 0; i < NumeroUsuarios; i++){
            if(msg.sender == Usuarios[i].direccionUsuario){
                if(Usuarios[i].estadoUsuario == true){ 
                    if(Usuarios[i].estadoUsuarioExpulsion == false){
                        if(Usuarios[i].EstadoPagoCuota == false){
                            if(msg.value > Usuarios[i].valorCuota){

                                emit MensajeAUsuario("El pago de su cuota ha sido realizado con exito, se le devolvera el cambio a su cuenta");
                                Usuarios[i].EstadoPagoCuota = true;
                                BalanceMontoAsignadoUsuario += Usuarios[i].valorCuota; //Acomula los montos totales de los pagos
                                                                                       //de todos los usuarios
                                Usuarios[i].BalanceUsuario += Usuarios[i].valorCuota;  //Acomula montos pagados por cada usuario
                            
                                payable(msg.sender).transfer(msg.value-Usuarios[i].valorCuota); //Se devuelve el excedente

                            }else if(msg.value < Usuarios[i].valorCuota){

                                emit MensajeAUsuario("El pago de su cuota es menor al establecido, el activo sera revertido");
                                payable(msg.sender).transfer(msg.value);

                            }else if(msg.value == Usuarios[i].valorCuota){

                                emit MensajeAUsuario("El pago de su cuota ha sido realizado con exito");
                                Usuarios[i].EstadoPagoCuota = true; 
                                BalanceMontoAsignadoUsuario += Usuarios[i].valorCuota;
                                Usuarios[i].BalanceUsuario += Usuarios[i].valorCuota;  //Acomula montos pagados por cada usuario
                            }
                        }else{
                            emit MensajeAUsuario("Ya ha realizado el pago para su cuota");
                            payable(msg.sender).transfer(msg.value); //Se revierte el pago al usuario no valido.
                        }
                    }else{
                        emit MensajeAUsuario("No puede pagar su cuota debido a que su usuario fue inhabilitado de la cadena\
                                              por no cumplir con un pago de cuota anterior");
                        payable(msg.sender).transfer(msg.value); //Se revierte el pago al usuario no valido.
                    }

                }else{
                    emit MensajeAUsuario("No puede participar ni realizar pago de cuotas\
                                          porque su usuario se encuentra inhabilitado");
                    payable(msg.sender).transfer(msg.value); //Se revierte el pago al usuario no valido.
                }
                UsuarioValido = true;
            }
        }

        if(UsuarioValido == false){
            emit MensajeAUsuario("Su direccion de usuario no ha sido agregada por el desplegador del contrato.\
                                  Por lo tanto su acceso es denegado para participar en esta cadena.");
            payable(msg.sender).transfer(msg.value); //Se revierte el pago al usuario no valido.
        }    
        UsuarioValido = false; 
    }


    //Función para acceder a toda la información de un determinado usuario
    function MostrarInformacionUsuarios(uint Indice) public view soloDuenoCadena returns(address,uint,uint,uint,bool,bool,bool)  {
            
        return (Usuarios[Indice].direccionUsuario,
                Usuarios[Indice].valorCuota,
                Usuarios[Indice].montoAsignado,
                Usuarios[Indice].BalanceUsuario,
                Usuarios[Indice].estadoUsuario,
                Usuarios[Indice].EstadoPagoCuota,
                Usuarios[Indice].EstadoMontoAsignado);
    }

    //Función para acceder a toda la información de los saldos del contrato de los distintos participantes.
    function MostrarBalanceUsuarios() public view soloDuenoCadena returns(int, int, uint)  {
        return (DuenoCadenaContractBalance,
                ownerContractBalance,
                BalanceDepositoDeGarantia);
    }
}
