using System.Collections;
using UnityEngine;

/// <summary>
/// サーフェス上の点pからuvを算出する
/// </summary>
public class CulcUV : MonoBehaviour
{
	private MeshFilter meshFilter;
	private Mesh mesh;

	private int index0;
	private int index1;
	private int index2;

	private Vector3 p1;
	private Vector3 p2;
	private Vector3 p3;
	private Vector3 p;

	private Vector3 v1;
	private Vector3 v2;
	private Vector3 vp;

	private Vector3 nv;

	private Vector3 a;
	private Vector3 b;
	private Vector3 c;

	private float d_ab;
	private float d_bc;

	private void Update()
	{
		if(Input.GetMouseButtonDown(0))
		{
			var ray = Camera.main.ScreenPointToRay(Input.mousePosition);
			RaycastHit hitInfo;
			if(Physics.Raycast(ray, out hitInfo))
			{
				meshFilter = hitInfo.transform.GetComponent<MeshFilter>();
				mesh = meshFilter.sharedMesh;
				var meshTriangles = mesh.triangles;
				var meshVertices = mesh.vertices;
				var meshUv = mesh.uv;

				for(var i = 0; i < meshTriangles.Length; i += 3)
				{
					#region 1.ある点pが与えられた3点において平面上に存在するか

					index0 = i + 0;
					index1 = i + 1;
					index2 = i + 2;

					p1 = meshVertices[meshTriangles[index0]];
					p2 = meshVertices[meshTriangles[index1]];
					p3 = meshVertices[meshTriangles[index2]];
					p = hitInfo.transform.InverseTransformPoint(hitInfo.point);

					v1 = p2 - p1;
					v2 = p3 - p1;
					vp = p - p1;

					nv = Vector3.Cross(v1, v2);
					var val = Vector3.Dot(nv, vp);
					//適当に小さい少数値で誤差をカバー
					if(!(-0.000001f < val && val < 0.000001f))
						continue;

					#endregion 1.ある点pが与えられた3点において平面上に存在するか

					#region 2.同一平面上に存在する点pが三角形内部に存在するか

					a = Vector3.Cross(p1 - p3, p - p1).normalized;
					b = Vector3.Cross(p2 - p1, p - p2).normalized;
					c = Vector3.Cross(p3 - p2, p - p3).normalized;

					d_ab = Vector3.Dot(a, b);
					d_bc = Vector3.Dot(b, c);

					if(!(0.999f < d_ab && 0.999f < d_bc))
						continue;

					#endregion 2.同一平面上に存在する点pが三角形内部に存在するか

					#region 3.点pのUV座標を求める

					var uv1 = meshUv[meshTriangles[index0]];
					var uv2 = meshUv[meshTriangles[index1]];
					var uv3 = meshUv[meshTriangles[index2]];

					//PerspectiveCollect(透視投影を考慮したUV補間)
					Matrix4x4 mvp = Camera.main.projectionMatrix * Camera.main.worldToCameraMatrix * hitInfo.transform.localToWorldMatrix;
					//各点をProjectionSpaceへの変換
					Vector4 p1_p = mvp * p1;
					Vector4 p2_p = mvp * p2;
					Vector4 p3_p = mvp * p3;
					Vector4 p_p = mvp * p;
					//通常座標への変換(ProjectionSpace)
					Vector2 p1_n = new Vector2(p1_p.x, p1_p.y) / p1_p.w;
					Vector2 p2_n = new Vector2(p2_p.x, p2_p.y) / p2_p.w;
					Vector2 p3_n = new Vector2(p3_p.x, p3_p.y) / p3_p.w;
					Vector2 p_n = new Vector2(p_p.x, p_p.y) / p_p.w;
					//頂点のなす三角形を点pにより3分割し、必要になる面積を計算
					var s = 0.5f * ((p2_n.x - p1_n.x) * (p3_n.y - p1_n.y) - (p2_n.y - p1_n.y) * (p3_n.x - p1_n.x));
					var s1 = 0.5f * ((p3_n.x - p_n.x) * (p1_n.y - p_n.y) - (p3_n.y - p_n.y) * (p1_n.x - p_n.x));
					var s2 = 0.5f * ((p1_n.x - p_n.x) * (p2_n.y - p_n.y) - (p1_n.y - p_n.y) * (p2_n.x - p_n.x));
					//面積比からuvを補間
					var u = s1 / s;
					var v = s2 / s;
					var w = 1 / ((1 - u - v) * 1 / p1_p.w + u * 1 / p2_p.w + v * 1 / p3_p.w);
					var uv = w * ((1 - u - v) * uv1 / p1_p.w + u * uv2 / p2_p.w + v * uv3 / p3_p.w);

					//uvが求まったよ!!!!
					Debug.Log(uv + ":" + hitInfo.textureCoord);
					return;

					#endregion 3.点pのUV座標を求める
				}
			}
		}
	}
}