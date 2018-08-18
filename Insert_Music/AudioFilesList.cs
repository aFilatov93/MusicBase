using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using TagLib;

namespace Insert_Music
{
    /// <summary>
    /// Класс, описывающий список объектов AudioFile,
    /// может выводит поля AudioFile в консоль, записывать и показывать пути к файлам
    /// </summary>
    class AudioFilesList
    {
        // путь к директории где хранятся мп3 файлы
        private string dir;
        // строковый массив со списком папок, включая подпапки
        private string[] subDirs;
        // строковый массив со списком путей к мп3 файлам
        private string[] tracksPaths;
        // основной список объектов AudioFile (см. класс AudioFile)
        public List<AudioFile> tracks { get; private set; }
        

        /// <summary>
        /// Конструктор, принимает путь к папке в которой должны быть мп3 файлы
        /// </summary>
        /// <param name="directory"></param>
        public AudioFilesList(string directory)
        {
            // присвоение введенного пути полю dir
            dir = directory;
            // если дерево папок не содержит мп3 файлов, выводит ошибку в консоль
            try
            {
                subDirs = Directory.GetFiles(@"" + dir, "*.mp3", SearchOption.AllDirectories);
            }
            catch (Exception ex)
            {
                ex = new Exception("Неправильный путь");
                return;
            }
            // добавление объектов AudioFile в список
            tracks  = subDirs.Select(file => new AudioFile(file)).ToList();
            // добавление путей к файлам в массив
            tracksPaths = new string[tracks.Count];
        }
    }
}
