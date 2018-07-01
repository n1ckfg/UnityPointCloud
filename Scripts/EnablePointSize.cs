// http://www.kamend.com/2014/05/rendering-a-point-cloud-inside-unity/
// https://github.com/srv/arsea/blob/master/Assets/Scripts/EnablePointSize.cs

#if UNITY_STANDALONE
#define IMPORT_GLENABLE
#endif

using UnityEngine;
using System;
using System.Collections;
using System.Runtime.InteropServices;

[ExecuteInEditMode]
public class EnablePointSize : MonoBehaviour {

    const UInt32 GL_VERTEX_PROGRAM_POINT_SIZE = 0x8642;
    const UInt32 GL_POINT_SMOOTH = 0x0B10;

    const string LibGLPath =
    #if UNITY_STANDALONE_WIN
        "opengl32.dll";
    #elif UNITY_STANDALONE_OSX
        "/System/Library/Frameworks/OpenGL.framework/OpenGL";
    #elif UNITY_STANDALONE_LINUX
        "libGL";  // Untested on Linux, this may not be correct
    #else
        null;   // OpenGL ES platforms don't require this feature
    #endif

    #if IMPORT_GLENABLE
        [DllImport(LibGLPath)]
        public static extern void glEnable(UInt32 cap);
     
        private bool mIsOpenGL;
     
        private void Start() {
            mIsOpenGL = SystemInfo.graphicsDeviceVersion.Contains("OpenGL");
        }
     
        private void OnPreRender() {
            if (mIsOpenGL) {
                glEnable(GL_VERTEX_PROGRAM_POINT_SIZE);
                glEnable(GL_POINT_SMOOTH);
            }
        }
    #endif

}