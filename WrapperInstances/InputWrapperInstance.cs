using MineLib.Core.Wrappers;

namespace MineLib.Windows.WrapperInstances
{
    public class InputWrapperInstance : IInputWrapper
    {
        public event OnKeys OnKey;

        public InputWrapperInstance() { }

        public void ShowKeyboard() { }

        public void HideKeyboard() { }
    }
}
