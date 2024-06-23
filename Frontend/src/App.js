import { useState } from 'react';
import { ethers } from 'ethers';

import './App.css';

const App = () => {


  const contractAddress = "0x0Cd97792009A2B41F0E5f0B5833cd6043aC8C6e4"; // Dirección del contrato
  const abi = `[{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"BalanceUsuario","type":"uint256"}],"name":"BalanceAsignadoUsuario","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"string","name":"mensaje1","type":"string"},{"indexed":false,"internalType":"uint256","name":"","type":"uint256"},{"indexed":false,"internalType":"string","name":"mensaje2","type":"string"},{"indexed":false,"internalType":"uint256","name":"","type":"uint256"}],"name":"Depuracion","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"string","name":"mensaje","type":"string"}],"name":"LogString","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"string","name":"mensaje","type":"string"}],"name":"MensajeAUsuario","type":"event"},{"inputs":[],"name":"ActualizarCuota","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"NuevaDireccion","type":"address"}],"name":"AgregarDireccionesDeUsuarios","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"DuenoCadena","outputs":[{"internalType":"address payable","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"IniciarContrato","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"MostrarBalanceUsuarios","outputs":[{"internalType":"int256","name":"","type":"int256"},{"internalType":"int256","name":"","type":"int256"},{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"Indice","type":"uint256"}],"name":"MostrarInformacionUsuarios","outputs":[{"internalType":"address","name":"","type":"address"},{"internalType":"uint256","name":"","type":"uint256"},{"internalType":"uint256","name":"","type":"uint256"},{"internalType":"uint256","name":"","type":"uint256"},{"internalType":"bool","name":"","type":"bool"},{"internalType":"bool","name":"","type":"bool"},{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"RecibirIngresosCuotasUsuarios","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[],"name":"RecibirIngresosDeParticipacionUsuarios","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[],"name":"RecibirPagoDuenoCadena","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"Usuarios","outputs":[{"internalType":"address","name":"direccionUsuario","type":"address"},{"internalType":"uint256","name":"valorCuota","type":"uint256"},{"internalType":"uint256","name":"montoAsignado","type":"uint256"},{"internalType":"uint256","name":"BalanceUsuario","type":"uint256"},{"internalType":"bool","name":"estadoUsuario","type":"bool"},{"internalType":"bool","name":"estadoUsuarioExpulsion","type":"bool"},{"internalType":"bool","name":"EstadoPagoCuota","type":"bool"},{"internalType":"bool","name":"EstadoMontoAsignado","type":"bool"}],"stateMutability":"view","type":"function"}]`;
  
  const [amount, setAmount] = useState('0'); // Estado para almacenar el monto del pago
  const [message, setMessage] = useState(''); // Estado para mostrar mensajes de éxito o error
  const [mensajeUsuario, setmensajeUsuario] = useState(''); // Estado para mostrar mensajes de éxito o error


  const handleChange = (event) => {
    setAmount(event.target.value); // Actualizar el estado del monto cuando cambia el valor del input
  };


  const RecibirPagoDuenoCadena = async () => {
    try {
      // Configurar la conexión con la red Ethereum
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      await provider.send("eth_requestAccounts", []); // Solicitar acceso a la cuenta

      const signer = provider.getSigner();
      const contract = new ethers.Contract(contractAddress, abi, signer);

      // Convertir el monto de GWei a Wei
      const amountToSend = ethers.utils.parseUnits(amount, 'gwei');

      // Enviar el pago a la función payable PagoInicial del contrato
      const tx = await contract.RecibirPagoDuenoCadena({
        value: amountToSend
      });

      // Esperar a que se confirme la transacción
      await tx.wait();

      // Escuchar eventos del contrato MensajeEmitido
      contract.on("MensajeAUsuario", (mensajeRecibido) => {
        console.log("Mensaje recibido:", mensajeRecibido);
        setmensajeUsuario(mensajeRecibido.args.mensajeUsuario); // Actualizar el estado con el mensaje recibido
      });

      setMessage(`Pago de ${amount} GWei enviado con éxito a la función payable del contrato.`);
    } catch (error) {
      console.error('Error al enviar el pago:', error);
      setMessage(`Error al enviar el pago: ${error.message}`);
    }
  };

  return (
    <div>
      <label>
        Monto a enviar (GWei):
        <input type="text" value={amount} onChange={handleChange} />
      </label>
      <button onClick={RecibirPagoDuenoCadena}>Enviar Pago</button>
      <p>{message}</p>
      <p>{mensajeUsuario}</p>
    </div>
  );
};

export default App;




//const contractAddress = "0x0Cd97792009A2B41F0E5f0B5833cd6043aC8C6e4";
//const ABI = 


//function App() {

  //const [data, setData] = useState(0);
  //const [amount, setData] = useState('0'); // Estado para almacenar el monto del pago de la direccion
                                                  // que inicia la cadena. 
  //const [message, setMessage] = useState(''); //Estado para mostrar mensajes de éxito o de error.
  

  //async function getDatabyContract () {
  //  try {
  //    const provider = new ethers.BrowserProvider(window.ethereum);
  //    const contract = new ethers.Contract(contractAddress, ABI, provider);
  //    const localData = await contract.getData();
  //    console.log("This is data from the contract " + localData);
  //  } catch (error) {
  //    console.log(error);
  //  }
  //}

//const handleInputChange = (event) => {
//  setData(event.target.value);
//};

//async function setDatabyContract () {
//  const provider = new ethers.BrowserProvider(window.ethereum);
//  const signer = await provider.getSigner();
//  const contract = new ethers.Contract(contractAddress, ABI, signer);
//  await contract.setData(data);
//  console.log("Executed a set operation, review the get operation");
//}

//const RecibirPagoDuenoCadena = async () => {
//  try {
//    const provider = new ethers.BrowserProvider(window.ethereum);
//    const signer = await provider.getSigner();
//    const contract = new ethers.Contract(contractAddress, ABI, signer);

    // Convertir el monto de GWei a wei
    //const amountToSend = ethers.parseEther(amount, 'gwei');

    //enviar el pago a la función payable del contrato
    //const tx = await WritableStreamDefaultWriter.sendTransaction({
    //  to: contractAddress,
    //  value: amountToSend,
    //  data: contract.interface.encodeFunctionData('RecibirPagoDuenoCadena', [])
    //});

    // Esperar a que se confirme la transacción
    //await tx.wait();

    //setMessage(`Pago de ${amount} Ether enviado con éxito a la función payable del contrato.`);

  //} catch (error) {
  //  console.error('Error al enviar el pago:', error);
  //  setMessage('Error al enviar el pago: ${error.message}');
  //}
//}

//  );
//}

//export default App;
