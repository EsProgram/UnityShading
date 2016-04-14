using System.Collections;
using UnityEngine;

[ExecuteInEditMode]
public class MVP : MonoBehaviour
{
  [SerializeField]
  private Material material;

  public void OnWillRenderObject()
  {
    if(material == null)
      return;

    Camera renderCamera = Camera.current;
    //Matrix4x4 m = gameObject.transform.localToWorldMatrix;
    Matrix4x4 m = GetComponent<Renderer>().localToWorldMatrix;
    Matrix4x4 v = renderCamera.worldToCameraMatrix;
    Matrix4x4 p = renderCamera.cameraType == CameraType.SceneView ?
      GL.GetGPUProjectionMatrix(renderCamera.projectionMatrix, true) : renderCamera.projectionMatrix;

    Matrix4x4 mvp = p * v * m;
    Matrix4x4 mv = v * m;

    //DynamicBatchingによって複数のオブジェクトでマテリアルを共有すると
    //matrixがオブジェクトごとに作用してくれない。こういった用途では
    //shaderで素直にUNITY_MATRIXを使うべき

    material.SetMatrix("mvp_matrix", mvp);
    material.SetMatrix("mv_matrix", mv);
    material.SetMatrix("v_matrix", v);
  }
}