using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Configuration;
using System.Windows.Forms;
using System.Data.SqlClient;

namespace Insert_Music
{
    public partial class MainForm : Form
    {
        static string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;
        static SqlConnection connection = new SqlConnection(connectionString);

        public MainForm()
        {
            InitializeComponent();
        }

        private void buttonOpenFolder_Click(object sender, EventArgs e)
        {
            folderBrowserD.ShowDialog();
            textBoxDirectory.Text = folderBrowserD.SelectedPath;
        }

        private void buttonAdd_Click(object sender, EventArgs e)
        {
            int insert = insertMusic(textBoxDirectory.Text);
            switch (insert)
            {
                case 0:
                    MessageBox.Show("Готово!");
                    break;
                case 1:
                    MessageBox.Show("В указанной директории нет мп3 файлов");
                    break;
                case 2:
                    MessageBox.Show("Не верно указан путь");
                    break;
            }
        }

        private int insertMusic(string directory)
        {
            bool switcher = true;

            // цикл добавления информации в БД
            while (switcher)
            {
                // если путь не указан, отлавливает ошибку NullReferenceException
                try
                {
                    // если путь существует, создает список с AudioFile из указанных директорий
                    AudioFilesList testAu = new AudioFilesList(directory);

                    // если путь существует, но в нем нет мп3 файлов, перезапускает цикл
                    if (testAu.tracks.Count > 0)
                    {
                        // добавляет информацию из объектов списка в БД
                        foreach (var Au1 in testAu.tracks)
                        {
                            DBManipulation.InsertTrack(Au1);
                        }

                        // выход из цикла
                        switcher = false;
                    }
                    //else Console.WriteLine("В папках нет .mp3 файлов");
                    else return 1;
                }
                catch (NullReferenceException ex)
                {
                    ex = new NullReferenceException();
                    return 2;
                }
            }
            
            return 0;
        }

        private void button1_Click(object sender, EventArgs e)
        {
            DBManipulation.ClearTables();
            MessageBox.Show("Готово!");
        }
    }
}
