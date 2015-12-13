using System;
using System.Net;

using Aragas.Core.Wrappers;

using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;

using MineLib.PGL;

using MineLib.Windows.WrapperInstances;

namespace MineLib.Windows
{
    public static class Program
    {
        static Program()
        {
            AppDomainWrapper.Instance = new AppDomainWrapperInstance();
            FileSystemWrapper.Instance = new FileSystemWrapperInstance();
            TCPClientWrapper.Instance = new TCPClientWrapperInstance();
            InputWrapper.Instance = new InputWrapperInstance();
            ThreadWrapper.Instance = new ThreadWrapperInstance();

            MineLib.Core.Extensions.PacketExtensions.Init();
        }

        public static void Main()
        {
            if (Type.GetType("Mono.Runtime") != null) // -- Running on Mono
                ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };

            using (var game = new Client(PlatformCode, false))
                game.Run();
        }

        private static void PlatformCode(Game client)
        {
            client.Window.ClientSizeChanged += ((Client) client).OnResize;
            client.IsMouseVisible = true;
            client.Window.Position = new Point(0, 0);
            client.Window.AllowUserResizing = true;

            ((Client) client).Resize(new Point(GraphicsAdapter.DefaultAdapter.CurrentDisplayMode.Width, GraphicsAdapter.DefaultAdapter.CurrentDisplayMode.Height));
            //((Client) client).PreferredBackBufferWidth = 1440;
            //((Client) client).PreferredBackBufferHeight = 900;
            //((Client) client).PreferredBackBufferWidth = 800;
            //((Client) client).PreferredBackBufferHeight = 600;
        }
    }
}