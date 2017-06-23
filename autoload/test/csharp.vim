let test#csharp#patterns = {
  \ 'test':      ['\v^\s*Scenario: (\w.*)', '\v^\s*public void (\w+)', '\v^\s*public async void (\w+)'],
  \ 'namespace': ['\v^\s*public class (\w+)', '\v^\s*public partial class (\w+)']
\}
