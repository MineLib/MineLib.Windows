using System;
using System.Net;

using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;

using MineLib.Core.Wrappers;

using MineLib.PCL.Graphics;

using MineLib.Windows.WrapperInstances;

namespace MineLib.Windows
{
    public static class Program
    {
        static Program()
        {
            AppDomainWrapper.Instance = new AppDomainWrapperInstance();
            FileSystemWrapper.Instance = new FileSystemWrapperInstance();
            NetworkTCPWrapper.Instance = new NetworkTCPWrapperInstance();
            InputWrapper.Instance = new InputWrapperInstance();
            ThreadWrapper.Instance = new ThreadWrapperInstance();
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
            ((Client) client).PreferredBackBufferWidth = 800;
            ((Client) client).PreferredBackBufferHeight = 600;
            client.IsMouseVisible = true;
            client.Window.Position = new Point(0, 0);
            ((Client) client).PreferredBackBufferWidth = GraphicsAdapter.DefaultAdapter.CurrentDisplayMode.Width;
            ((Client) client).PreferredBackBufferHeight = GraphicsAdapter.DefaultAdapter.CurrentDisplayMode.Height;
        }
    }
}