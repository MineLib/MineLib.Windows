using System;

using Aragas.Core.Wrappers;

namespace MineLib.Windows.WrapperInstances
{
    public class InputWrapperInstance : IInputWrapper
    {
        public event EventHandler<KeyPressedEventArgs> KeyPressed;

        public InputWrapperInstance() { }

        public void ShowKeyboard() { }

        public void HideKeyboard() { }

        public void ConsoleWrite(string message) { }

        public void LogWriteLine(string message) { }
    }
}
