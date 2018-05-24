using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace ImageConv
{
    class Program
    {
        static void ShowInfo(string[] args)
        {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < args.Length; ++i)
            {
                sb.AppendLine(String.Format(("args[{0}]==\"{1}\""), i, args[i]));
            }
            MessageBox.Show(sb.ToString());
        }
        static void Call(string cli_exe,string[] cli_arguments)
        {
            Process p = new Process();
            p.StartInfo.FileName = cli_exe;
            p.StartInfo.Arguments = string.Join(" ", cli_arguments);
            p.StartInfo.WorkingDirectory = Environment.CurrentDirectory;
            p.StartInfo.CreateNoWindow = true;
            p.StartInfo.UseShellExecute = false;
            p.Start();
        }
        static void PngToWebp(string file)
        {
            string newfile = Path.ChangeExtension(file, ".webp");
            Call("cwebp.exe", new string[] { file, "-o", newfile });
        }
        static void WebpToPng(string file)
        {
            string newfile = Path.ChangeExtension(file, ".png");
            Call("dwebp.exe", new string[] { file, "-o", newfile });
        }
        static void ConvertSwitch(string cmd, string file)
        {
            switch(cmd)
            {
                case "--png-to-webp":
                    //конвертируем из png в webp
                    PngToWebp(file);
                    break;
                case "--webp-to-png":
                    //конвертируем из png в webp
                    WebpToPng(file);
                    break;
                default:
                    break;
            }
        }
        static void Main(string[] args)
        {
            if (args.Length != 2) return;

            string cmd = args[0];
            string file = args[1];

            if (!File.Exists(file)) return;

            try
            {
                ConvertSwitch(cmd, file);
            }
            catch(Exception E)
            {
                MessageBox.Show(E.Message);
            }
        }
    }
}
