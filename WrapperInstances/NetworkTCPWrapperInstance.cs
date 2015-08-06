using System.Net.Sockets;
using System.Threading;
using System.Threading.Tasks;

using MineLib.Core.Wrappers;

namespace MineLib.Windows.WrapperInstances
{
    public class NetworkTCPWrapperInstance : INetworkTCP
    {
        public bool Connected { get { return !IsDisposed && Client != null && Client.Connected; } }


        private TcpClient Client { get; set; }
        private NetworkStream Stream { get; set; }
        private bool IsDisposed { get; set; }


        public void Connect(string ip, ushort port)
        {
            Client = new TcpClient(ip, port);
            Stream = new NetworkStream(Client.Client);
        }
        public void Disconnect()
        {
            if (Connected)
                Client.Client.Disconnect(false);
        }

        public void Send(byte[] bytes, int offset, int count)
        {
            if(!IsDisposed)
                Stream.Write(bytes, offset, count);
        }
        public int Receive(byte[] buffer, int offset, int count)
        {
            if (!IsDisposed)
                return Stream.Read(buffer, offset, count);
            else
                return -1;
        }


        public async Task ConnectAsync(string ip, ushort port)
        {
            Client = new TcpClient();
            await Client.ConnectAsync(ip, port);

            Stream = new NetworkStream(Client.Client);
        }
        public bool DisconnectAsync()
        {
            if (Connected)
                return Client.Client.DisconnectAsync(new SocketAsyncEventArgs {DisconnectReuseSocket = false});
            else
                return true;
        }

        public Task SendAsync(byte[] bytes, int offset, int count)
        {
            if (!IsDisposed)
                return Stream.WriteAsync(bytes, offset, count);
            else
                return null;
        }
        public Task<int> ReceiveAsync(byte[] bytes, int offset, int count)
        {
            if (!IsDisposed)
                return Stream.ReadAsync(bytes, offset, count);
            else
                return null;
        }


        public INetworkTCP NewInstance()
        {
            return new NetworkTCPWrapperInstance();
        }


        public void Dispose()
        {
            IsDisposed = true;

            Thread.Sleep(500);

            if (Client != null)
                Client.Close();

            if (Stream != null)
                Stream.Dispose();
        }
    }
}
