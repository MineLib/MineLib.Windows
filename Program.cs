using System;
using System.Net;
using System.Reflection;

using MineLib.PCL.Graphics;

using PCLStorage;

namespace MineLib.Windows
{
    /// <summary>
    /// The main class.
    /// </summary>
    public static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            if (Type.GetType("Mono.Runtime") != null) // -- Running on Mono
                ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };

            var game = new Client(new NetworkTCPWindows());
            game.LoadAssembly += ClientOnLoadAssembly;
            game.GetStorage += GetStorage;
            game.Run();

            game.Dispose();
        }


        private static Assembly ClientOnLoadAssembly(object sender, byte[] assembly)
        {
            return Assembly.Load(assembly);
        }

        private static IFolder GetStorage(object sender)
        {
            return FileSystem.Current.LocalStorage;
        }
    }
}
